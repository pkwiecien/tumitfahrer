class Api::V1::MessagesController < ApiController
  respond_to :xml, :json

  # GET /api/v1/users/:user_id/messages
  def index
    user = User.find_by(id: params[:user_id])
    return respond_with conversations: [], status: :not_found if user.nil?
    senders = Message.select(:sender_id).where(receiver_id: user.id).map(&:sender_id).uniq
    receivers = Message.select(:receiver_id).where(sender_id: user.id).map(&:receiver_id).uniq

    partner_ids = (senders + receivers).uniq
    results = []
    partner_ids.each do |partner_id|
      sent = Message.where(sender_id: user.id, receiver_id: partner_id).order("created_at").last
      received = Message.where(sender_id: partner_id, receiver_id: user.id).order("created_at").last

      if received.nil? || (!sent.nil? && sent[:created_at]>received[:created_at])
        results.append(sent)
      else
        results.append(received)
      end
    end
    respond_with conversations: results, status: :ok
  end

  # GET /api/v1/users/:user_id/messages/:id
  def show
    user = User.find_by(id: params[:user_id])
    other_user = User.find_by(id: params[:id])
    return respond_with messages: [], status: :bad_request if user.nil? || other_user.nil?

    sent_messages = user.sent_messages.where(receiver_id: other_user.id)
    received_messages = user.received_messages.where(sender_id: other_user.id)
    messages = sent_messages + received_messages

    respond_with :messages => messages, status: :ok
  end

  # POST /api/v1/users/:user_id/messages
  def create
    user = User.find_by(id: params[:user_id])
    other_user = User.find_by(id: params[:receiver_id])
    return render :status => :not_found if user.nil? || other_user.nil?

    message = user.send_message!(other_user, params[:content])
    unless message.nil?
      send_android_push(message)
      respond_to do |format|
        format.xml { render xml: {:status => :created} }
        format.any { render json: {:status => :created} }
      end
    else
      respond_to do |format|
        format.xml { render xml: {:status => :bad_request} }
        format.any { render json: {:status => :bad_request} }
      end
    end
  end

  # PUT /api/v1messages/:id
  def update
    message = Message.find_by(id: params[:message_id])
    if message.nil?
      return respond_to do |format|
        format.xml { render xml: {:status => :not_found} }
        format.any { render json: {:status => :not_found} }
      end
    end

    message.update_attribute(:is_seen, params[:is_seen])
    respond_to do |format|
      format.xml { render xml: {:status => :ok} }
      format.any { render json: {:status => :ok} }
    end
  end

  private

  def send_android_push(message)
    begin
      devices = User.find_by(id: message[:sender_id]).devices.where(platform: "android")
      registration_ids = []
      devices.each do |d|
        registration_ids.append(d[:token])
      end

      options = {}
      options[:type] = :nachricht
      options[:message] = message[:content]
      options[:time] = message[:created_at]
      options[:absender] = User.find_by(id: message[:sender_id]).first_name

      logger.debug "Sending push notification with reg_ids : #{registration_ids} and options: #{options}"
      response = GcmUtils.send_android_push_notifications(registration_ids, options)
      logger.debug "Response: #{response}"
    rescue
      logger.debug "Could not send push notification"
    end
  end

end
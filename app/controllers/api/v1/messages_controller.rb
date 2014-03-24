class Api::V1::MessagesController < ApiController
  respond_to :xml, :json

  def index
    begin
      user = User.find_by(id: params[:user_id])
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
      respond_with :conversations => results
    rescue
      respond_with :status => 400
    end
  end

  def show
    begin
      user = User.find_by(id: params[:user_id])
      other_user = User.find_by(id: params[:id])
      sent_messages = user.sent_messages.where(receiver_id: other_user.id)
      received_messages = user.received_messages.where(sender_id: other_user.id)
      messages = sent_messages + received_messages

      respond_with :messages => messages
    rescue
      respond_with :status => 400
    end
  end

  def create
    begin
      user = User.find_by(id: params[:user_id])
      other_user = User.find_by(id: params[:receiver_id])
      message = user.send_message!(other_user, params[:content])
      unless message.nil?
        send_android_push(message)
      end
      respond_with :status => 200
    rescue
      respond_with :status => 400
    end

  end

  def update
    message = Message.find_by(id: params[:message_id])
    return respond_with :status => 400 if message.nil?

    message.update_attribute(:is_seen, params[:is_seen])
    respond_with :status => 200
  end

  private

  def send_android_push(message)
    begin
      devices = User.find_by(id: message[:receiver_id]).devices.where(platform: "android")
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
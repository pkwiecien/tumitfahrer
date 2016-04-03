class Api::V2::MessagesController < ApiController
  respond_to :xml, :json

  # POST /api/v2/rides/:ride_id/conversations/:conversation_id/messages
  def create
    user_from_api_key = User.find_by(api_key: request.headers[:apiKey])
    return render json: {message: []}, status: :unauthorized if user_from_api_key.nil?

    conversation = Conversation.find_by(id: params[:conversation_id])
    return render json: {status: :not_found} if conversation.nil?

    message = conversation.create_message(params[:content], params[:sender_id],
                                           params[:receiver_id])

    if message.nil?
      return render json: {message: []}, status: :bad_request
    else
      render json: message, status: :ok
    end
  end

  private

end
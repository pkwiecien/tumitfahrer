class Api::V2::MessagesController < ApiController
  respond_to :xml, :json

  # POST /api/v2/rides/:ride_id/conversations/:conversation_id/messages
  def create
    conversation = Conversation.find_by(id: params[:conversation_id])
    return render json: {status: :not_found} if conversation.nil?

    message = conversation.create_message(params[:content], params[:sender_id],
                                           params[:receiver_id])

    if message.nil?
      return render json: {message: "Could not save message"}, status: :bad_request
    else
      render json: message, status: :ok
    end
  end

  private

end
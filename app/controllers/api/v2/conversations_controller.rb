class Api::V2::ConversationsController < ApiController
  respond_to :xml, :json

  @@num_page_results = 10

  # GET /api/v2/rides/:ride_id/conversations
  def index

    ride = Ride.find_by(id: params[:ride_id])
    return respond_with message_list: [], status: :not_found if ride.nil?

    respond_with ride.conversations, status: :ok

  end

  # GET /api/v2/rides/:ride_id/conversations/:id
  def show

    ride = Ride.find_by(id: params[:ride_id])
    return respond_with conversation: [], status: :not_found if ride.nil?

    conversation = ride.conversations.find_by(id: params[:id])
    if conversation.nil?
      respond_with conversation: [], status: :ok
    else
      respond_with conversation, status: :ok
    end

  end

  private

end
class Api::V1::SearchesController < ApiController
  respond_to :json, :xml

  def show
    render json: {:status => :ok}
  end

  def create
  end
end

class Api::V1::RidesController < ApiController
  respond_to :json, :xml
  before_action :restrict_access, only: [:create]

  def index
    @rides = Ride.all
    respond_to do |format|
      format.json { render json: @rides }
      format.xml { render xml: @rides }
    end
  end

  def show
    @ride = Ride.find(params[:id])
    respond_to do |format|
      format.json { render json: @ride }
      format.xml { render xml: @ride }
    end
  end

  def create

  end

  private

  def restrict_access
    api_key = ApiKey.find_by_access_token(params[:access_token])
    head :unauthorized unless api_key
  end
end

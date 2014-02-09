class Api::V1::RidesController < ApiController
  respond_to :json, :xml
  before_action :restrict_access, only: [:index]

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
    authenticate_or_request_with_http_token do |key, options|
      User.exists?(api_key: key)
    end
  end
end

class Api::V1::DevicesController < ApplicationController
  include GcmUtils
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

  # GET /api/v1/users/:user_id/devices
  def index
    user = User.find_by(id: params[:user_id])
    if user.nil?
      return respond_with :status => 400
    else
      respond_with devices: user.devices
    end
  end

  # POST /api/v1/users/:user_id/devices
  def create
    user = User.find_by(id: params[:user_id])
    logger.debug "we are here and the user is : #{user.id} and params are: #{params} and #{user.devices}"

    if user.devices.find_by(token: params[:device][:token]).nil?
      user.devices.create!(params[:device][:token], params[:device][:enabled], params[:device][:platform])
    end
    render json: {:status => 200}
  end

  private

  def device_params
    params.require(:device).permit(:token, :enabled, :platform)
  end
end

class Api::V1::DevicesController < ApplicationController
  include GcmUtils
  respond_to :xml, :json
  protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format == 'application/json' }

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
    begin
      if user.devices.find_by(token: params[:device][:token]).nil?
        user.register_device!(params[:device][:token], params[:device][:enabled], params[:device][:platform])
      end
      respond_with :status => 200
    rescue
      logger.debug "Could not register device for user #{params[:user_id]}"
      respond_with :status => 400
    end
  end


  private

  def device_params
    params.require(:device).permit(:token, :enabled, :platform)
  end
end

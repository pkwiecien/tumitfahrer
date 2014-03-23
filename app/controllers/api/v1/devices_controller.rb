class Api::V1::DevicesController < ApplicationController
  include GcmUtils
  respond_to :xml, :json
  protect_from_forgery with: :null_session, :if => Proc.new { |c| c.request.format == 'application/json' }

  def index
    user = User.find_by(id: params[:user_id])

    respond_to do |format|
      format.json { render json: {devices: user.devices} }
      format.xml { render xml: {devices: user.devices} }
    end

  end

  def create
    user = User.find_by(id: params[:user_id])
    begin
      if user.devices.find_by(token: params[:device][:token]).nil?
        user.register_device!(params[:device][:token], params[:device][:enabled], params[:device][:platform])
      end
      render json: {:status => 200}
    rescue
      logger.debug "Could not register device for user #{user.id}"
      render json: {:status => 400}
    end
  end


  private

  def device_params
    params.require(:device).permit(:token, :enabled, :platform)
  end
end

class Api::V1::DevicesController < ApplicationController
  include GcmUtils
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

  # GET /api/v1/users/:user_id/devices
  def index
    user = User.find_by(id: params[:user_id])
    if user.nil?
      respond_with devices: [], status: :not_found
    else
      respond_with devices: user.devices, status: :ok
    end
  end

  # POST /api/v1/users/:user_id/devices
  def create
    user = User.find_by(id: params[:user_id])
    if user.nil?
      return respond_to do |format|
        format.xml { render xml: {:status => :not_found} }
        format.any { render json: {:status => :not_found} }
      end
    end

    if user.devices.find_by(token: params[:device][:token]).nil?
      user.devices.create!(token: params[:device][:token], enabled: params[:device][:enabled],
                           platform: params[:device][:platform])
    end

    respond_to do |format|
      format.xml { render xml: {:status => :created} }
      format.any { render json: {:status => :created} }
    end
  end

  private

  def device_params
    params.require(:device).permit(:token, :enabled, :platform)
  end


end

class Api::V1::DevicesController < ApplicationController
  include GcmUtils
  skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

  # GET /api/v1/users/:user_id/devices
  def index
    user = User.find_by(id: params[:user_id])
    if user.nil?
      respond_with devices: [], status: :bad_request
    else
      respond_with devices: user.devices, status: :ok
    end
  end

  # POST /api/v1/users/:user_id/devices
  def create
    user = User.find_by(id: params[:user_id])
    if user.nil?
      return respond_to do |format|
        format.xml { render xml: {:status => :bad_request} }
        format.any { render json: {:status => :bad_request} }
      end
    end

    if user.devices.find_by(token: params[:device][:token]).nil?
      user.devices.create!(params[:device][:token], params[:device][:enabled], params[:device][:platform])
    end

    respond_to do |format|
      format.xml { render xml: {:status => :ok} }
      format.any { render json: {:status => :ok} }
    end
  end

  private

  def device_params
    params.require(:device).permit(:token, :enabled, :platform)
  end


end

class Api::V2::DevicesController < ApplicationController
  include GcmUtils
  # skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

  # GET /api/v2/users/:user_id/devices
  def index
    user_from_api_key = User.find_by(api_key: request.headers[:apiKey])
    return render json: {devices: [], message: "Access denied"}, status: :unauthorized if user_from_api_key.nil?

    user = User.find_by(id: params[:user_id])
    if user.nil?
      respond_to do |format|
        format.json { render json: {:devices => []}, status: :not_found }
        format.xml { render xml: {:devices => []}, status: :not_found }
      end
    else
      if params.has_key?(:platform)
        respond_with devices: user.devices.where(platform: params[:platform]), status: :ok
      else
        respond_with devices: user.devices, status: :ok
      end
    end
  end

  # POST /api/v2/users/:user_id/devices
  def create
    user_from_api_key = User.find_by(api_key: request.headers[:apiKey])
    return render json: {message: "Access denied"}, status: :unauthorized if user_from_api_key.nil?

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
      format.xml { render xml: {message: "device saved"}, :status => :created }
      format.any { render json: {message: "device saved"}, :status => :created }
    end
  end

  private

  def device_params
    params.require(:device).permit(:token, :enabled, :platform, :language)
  end

end

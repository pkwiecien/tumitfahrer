class Api::V1::RatingsController < ApiController
  respond_to :xml, :json

  def index

    render json: {:result => "1"}

  end

  def show

  end

  def create
    user = User.find_by(id: params[:user_id])
    from_user = User.find_by(id: params[:from_user_id])
    result = user.ratings.create!(from_user: from_user.id, ride_id: params[:ride_id], rating_type: params[:rating_type])

    unless result.nil?
      render json: {:result => "1"}
    else
      render json: {:result => "0"}
    end
  end


end
class Api::V2::ActivitiesController < ApplicationController
  # skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

  # GET /api/v2/activities
  def index

    if params.has_key?(:page)
      @activities = {}
      campus_rides = Ride.order(updated_at: :desc).where(ride_type: 0).offset(params[:page].to_i*6).limit(6)
      activity_rides = Ride.order(updated_at: :desc).where(ride_type: 1).offset(params[:page].to_i*6).limit(6)
      requested_rides = Ride.order(updated_at: :desc).where(ride_type: 2).offset(params[:page].to_i*6).limit(6)
      @activities[:rides] = campus_rides + activity_rides + requested_rides
      @activities[:ride_searches] = RideSearch.order(updated_at: :desc).offset(params[:page].to_i*6).limit(6)
      @activities[:ratings] = Rating.order(updated_at: :desc).offset(params[:page].to_i*6).limit(6)
      @activities[:requests] = Request.order(updated_at: :desc).offset(params[:page].to_i*6).limit(6)

      respond_with :activities => @activities, status: :ok
    end
  end

end

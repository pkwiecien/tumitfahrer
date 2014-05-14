class Api::V2::ActivitiesController < ApplicationController
  # skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

  # GET /api/v2/activities
  def index

    @activities = {}
    campus_rides = Ride.order(updated_at: :desc).where(ride_type: 0).first(5)
    activity_rides = Ride.order(updated_at: :desc).where(ride_type: 1).first(5)
    requested_rides = Ride.order(updated_at: :desc).where(ride_type: 2).first(5)
    @activities[:rides] = campus_rides + activity_rides + requested_rides
    @activities[:ride_searches] = RideSearch.order(updated_at: :desc).first(5)
    @activities[:ratings] = Rating.order(updated_at: :desc).first(5)
    @activities[:requests] = Request.order(updated_at: :desc).first(5)

    respond_with :activities => @activities, status: :ok
  end

end

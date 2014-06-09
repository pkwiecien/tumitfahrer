class Api::V2::ActivitiesController < ApplicationController
  # skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

  @@num_page_results = 10

  # GET /api/v2/activities
  def index

      @activities = {id: params[:activity_id].to_i}
      campus_rides = Ride.order(created_at: :desc).where("ride_type = ? AND departure_time > ?", 0, Time.now).limit(@@num_page_results)
      activity_rides = Ride.order(created_at: :desc).where("ride_type = ? AND departure_time > ?", 1, Time.now).limit(@@num_page_results)

      @activities[:rides] = campus_rides + activity_rides
      @activities[:ride_searches] = RideSearch.order(created_at: :desc).limit(@@num_page_results)
      @activities[:requests] = Request.order(created_at: :desc).limit(@@num_page_results)

      respond_with :activities => @activities, status: :ok

  end

end

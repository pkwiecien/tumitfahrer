class Api::V2::ActivitiesController < ApplicationController
  # skip_before_filter :verify_authenticity_token
  respond_to :xml, :json

  @@num_page_results = 10

  # GET /api/v2/activities
  def index
    page = 0

    if params.has_key?(:page)
      page = params[:page].to_i
    end

      @activities = {id: 1}
      campus_rides = Ride.order(updated_at: :desc).where(ride_type: 0).offset(page*@@num_page_results).limit(@@num_page_results)
      activity_rides = Ride.order(updated_at: :desc).where(ride_type: 1).offset(page*@@num_page_results).limit(@@num_page_results)

      @activities[:rides] = campus_rides + activity_rides
      @activities[:ride_searches] = RideSearch.order(updated_at: :desc).offset(page*@@num_page_results).limit(@@num_page_results)
      @activities[:requests] = Request.order(updated_at: :desc).offset(page*@@num_page_results).limit(@@num_page_results)

      respond_with :activities => @activities, status: :ok

  end

end

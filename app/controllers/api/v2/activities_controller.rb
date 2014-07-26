class Api::V2::ActivitiesController < ApplicationController
  # skip_before_filter :verify_authenticity_token
  respond_to :xml, :json
  before_filter :check_format, only: [:show]

  @@num_page_results = 10

  # GET /api/v2/activities
  def index

    @activities = {id: params[:activity_id].to_i}
    campus_rides = Ride.order(created_at: :desc).where("ride_type = ? AND departure_time > ?", 0, Time.now).limit(@@num_page_results)
    activity_rides = Ride.order(created_at: :desc).where("ride_type = ? AND departure_time > ?", 1, Time.now).limit(@@num_page_results)

    all_rides = campus_rides + activity_rides

    result_rides = []
    all_rides.each do |ride|
      ride_attributes = ride.attributes
      ride_attributes[:is_ride_request] = ride.is_ride_request
      result_rides.append(ride_attributes)
    end
    @activities[:rides] = result_rides

    @activities[:ride_searches] = RideSearch.order(created_at: :desc).limit(@@num_page_results)
    @activities[:requests] = Request.order(created_at: :desc).limit(@@num_page_results)

    respond_with :activities => @activities, status: :ok

  end

  # GET /api/v2/activities/badges?campus_updated_at='2012-02-03 12:30'&user_id=id
  def get_badge_counter

    campus_updated_at = params[:campus_updated_at]
    activity_updated_at = params[:activity_updated_at]
    timeline_updated_at = params[:timeline_updated_at]
    my_rides_updated_at = params[:my_rides_updated_at]

    if campus_updated_at.nil?
      campus_updated_at = Time.zone.now
    end

    if activity_updated_at.nil?
      activity_updated_at = Time.zone.now
    end

    if timeline_updated_at.nil?
      timeline_updated_at = Time.zone.now
    end

    if my_rides_updated_at.nil?
      my_rides_updated_at = Time.zone.now
    end

    user_id = params[:user_id]

    campus_counter = Ride.where("ride_type = 0 AND created_at > ? AND user_id <> ?", campus_updated_at, user_id).count
    activity_counter = Ride.where("ride_type = 1 AND created_at > ? AND user_id <> ?", activity_updated_at, user_id).count

    ride_searches_counter = RideSearch.where("created_at > ? AND user_id <> ?", timeline_updated_at, user_id).count
    requests_counter = Request.where("created_at > ? AND passenger_id <> ?", timeline_updated_at, user_id).count

    new_passenger =  Ride.joins(:relationships).where("relationships.is_driving = false AND relationships.user_id = ? AND relationships.created_at > ?", user_id, my_rides_updated_at).count
    new_requests = Ride.joins(:requests).where("requests.passenger_id = ? AND requests.created_at > ?", user_id, my_rides_updated_at).count

    news_counter = campus_counter + activity_counter + ride_searches_counter + requests_counter
    user_news = new_passenger + new_requests

    @badge = { id: 0, created_at: Time.zone.now}
    @badge[:timeline_badge] = news_counter
    @badge[:timeline_updated_at] = timeline_updated_at
    @badge[:campus_badge] = campus_counter
    @badge[:campus_updated_at] = campus_updated_at
    @badge[:activity_badge] = activity_counter
    @badge[:activity_updated_at] = activity_updated_at
    @badge[:my_rides_badge] = user_news
    @badge[:my_rides_updated_at] = my_rides_updated_at

    respond_to do |format|
      format.xml { render xml: {badge_counter: @badge}, :status => :ok }
      format.json { render json: {badge_counter: @badge}, :status => :ok }
    end

  end

end

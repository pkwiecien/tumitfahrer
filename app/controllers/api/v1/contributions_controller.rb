class Api::V1::ContributionsController < ApiController
  respond_to :xml, :json

  def index
    @user = User.find_by(id: params[:user_id])
    @contributions = @user.contributions

    respond_to do |format|
      format.json { render json: {:contributions => @contributions} }
      format.xml { render xml: @contributions }
    end

  end

  def show

  end

  def create
    user = User.find_by(id: params[:user_id])
    ride = Ride.find_by(id: params[:ride_id])
    price = ride[:price]
    distance = user.rides.find_by(id: params[:ride_id])[:realtime_km]
    driver_id = ride.driver[:id]
    project_id = ride.project[:id]

    contribution_amount = price*distance
    user.update_attribute(:unbound_contributions, contribution_amount)
    user.contributions.update_attributes(amount: contribution_amount, project_id: project_id)
    user.rides.find_by(id: ride.id).update_attribute(:is_paid, true)
    render json: {:status => 200}

  end


end

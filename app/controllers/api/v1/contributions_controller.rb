class Api::V1::ContributionsController < ApiController
  respond_to :xml, :json

  # GET /api/v1/users/:user_id/contributions
  def index
    @user = User.find_by(id: params[:user_id])
    return respond_with :contributions => [] if @user.nil?
    @contributions = @user.contributions
    respond_with :contributions => @contributions
  end

  # POST /api/v1/users/:user_id/rides/:ride_id/contributions
  def contribute_to_ride
    begin
      user = User.find_by(id: params[:user_id])
      ride = Ride.find_by(id: params[:ride_id])
      price = ride[:price]
      distance = user.rides.find_by(id: params[:ride_id])[:realtime_km]
      project_id = ride.project[:id]

      contribution_amount = price*distance
      user.update_attribute(:unbound_contributions, contribution_amount)
      user.contributions.update_attributes(amount: contribution_amount, project_id: project_id)
      user.rides.find_by(id: ride.id).update_attribute(:is_paid, true)
      respond_with :status => 200
    rescue
      respond_with :status => 400
    end
  end

  # POST /api/v1/users/:user_id/contributions
  def create
    if params[:contribution] && params[:contribution][:amount]
      user = User.find_by(id: params[:user_id])
      return respond_with :status => 400 if user.nil?
      user.contributions.create!(project_id: params[:contribution][:project_id], amount: params[:contribution][:amount],
                                 user_id: params[:user_id])
      respond_with :status => 200
    end
  end

  # PUT /api/v1/users/:user_id/contributions
  def update
    user = User.find_by(id: params[:user_id])
    return respond_with :status => 400 if user.nil?

    user.contributions.find_by(project_id: params[:id]).update_attributes(contribution_params)

    respond_with :status => 200
  end

  # DELETE /api/v1/users/:user_id/contributions
  def destroy
    begin
      user = User.find_by(id: params[:user_id])
      contribution = user.contributions.find_by(project_id: params[:id], user_id: user.id)
      user.update_attribute(:unbound_contributions, user[:unbound_contributions]+contribution.amount)
      contribution.destroy
      respond_with :status => 200
    rescue
      respond_with :status => 400
    end
  end

  private

  # validate post parameters
  def contribution_params
    params.require(:contribution).permit(:amount)
  end


end

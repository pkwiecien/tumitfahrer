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
    if params[:contribution] && params[:contribution][:amount]
      user = User.find_by(id: params[:user_id])
      if user.nil?
        render json: {:status => 400}
      end

      owner_id = Project.find_by(id: params[:contribution][:project_id]).owner_id
      user.contributions.create!(project_id: params[:contribution][:project_id], amount: params[:contribution][:amount],
                                 user_id: params[:user_id])
      render json: {:status => 200}
    else
      user = User.find_by(id: params[:user_id])
      ride = Ride.find_by(id: params[:ride_id])
      price = ride[:price]
      distance = user.rides.find_by(id: params[:ride_id])[:realtime_km]
      driver_id = ride[:driver_id]
      project_id = ride.project[:id]

      contribution_amount = price*distance
      user.update_attribute(:unbound_contributions, contribution_amount)
      user.contributions.update_attributes(amount: contribution_amount, project_id: project_id)
      user.rides.find_by(id: ride.id).update_attribute(:is_paid, true)
      render json: {:status => 200}
    end
  end

  def update
    user = User.find_by(id: params[:user_id])
    if user.nil?
      render json: {:status => 400}
    end

    user.contributions.find_by(project_id: params[:id]).update_attributes(contribution_params)
    render json: {:status => 200}

  end

  def destroy
    user = User.find_by(id: params[:user_id])
    contribution = user.contributions.find_by(project_id: params[:contribution][:project_id], user_id: user.id)
    user.update_attribute(:unbound_contributions, user[:unbound_contributions]+contribution.amount)
    contribution.destroy
    render json: {:status => 200}
  end

  private


  def contribution_params
    params.require(:contribution).permit(:amount)
  end


end

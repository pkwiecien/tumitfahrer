class Api::V1::PaymentsController < ApiController
  respond_to :xml, :json

  def index
    user = User.find_by(id: params[:user_id])

    result = []
    if params.has_key?(:pending)
      result = payments(paid=false, user)
    else
      result = payments(paid=true, user)
    end
    respond_with :payments => result
  end

  def show

  end

  def create
    to_user = User.find_by(id: params[:user_id])
    from_user = User.find_by(id: params[:from_user_id])
    payment = Payment.create!(from_user_id: from_user.id, to_user_id: to_user.id, ride_id: params[:ride_id], amount: params[:amount])

    if payment.save
      respond_with :status => 200
    else
      respond_with :status => 400
    end
  end

  private

  def payments(paid=true, user)
    result = []
    user.rides_as_passenger.each do |p|
      if p[:is_paid] == paid
        payment = {}
        payment[:ride_id] = p[:id]
        payment[:is_paid] = p[:is_paid]
        payment[:driver_id] = p.driver.id
        result.append(payment)
      end
    end
    result
  end


end
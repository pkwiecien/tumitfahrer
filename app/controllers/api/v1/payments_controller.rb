class Api::V1::PaymentsController < ApiController
  respond_to :xml, :json

  # GET /api/v1/users/:user_id/payments
  def index
    user = User.find_by(id: params[:user_id])
    return respond_with payments: [], status: :not_found if user.nil?

    result = []
    if params.has_key?(:pending)
      result = payments(paid=false, user)
    else
      result = payments(paid=true, user)
    end

    respond_with payments: result, status: :ok
  end

  # POST /api/v1/users/:user_id/payments?from_user_id=X&ride_id=Y&amount=Z
  def create
    to_user = User.find_by(id: params[:user_id])
    from_user = User.find_by(id: params[:from_user_id])
    return respond_with payment: [], status: :not_found if to_user.nil? || from_user.nil?
    payment = to_user.payments_received.create!(from_user_id: from_user.id,
                                                ride_id: params[:ride_id], amount: params[:amount])

    unless payment.nil?
      respond_with payment, status: :ok
    else
      respond_with payment, status: :bad_request
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
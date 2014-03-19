class Device < ActiveRecord::Base
  belongs_to :user

  def create

    # @device = Device.create(user_id: current_user, token: params[:token], platform: params[:platform])

  end
end

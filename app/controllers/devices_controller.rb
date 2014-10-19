class DevicesController < ApplicationController

	def visiom_devices
		ip = params[:ip]
		visiom = Device.find_by_id(3)
		visiom.token = ip
		visiom.save!
	end

end

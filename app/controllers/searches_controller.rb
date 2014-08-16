require 'will_paginate/array'

class SearchesController < ApplicationController

  URL = 'http://www.panoramio.com/map/get_panoramas.php'
  DEFAULT_OPTIONS = {
      :set => :public, # Cant be :public, :full, or a USER ID number
      :size => :medium, # Cant be :original, :medium (default value), :small, :thumbnail, :square, :mini_square
      :from => 0,
      :to => 1,
      :mapfilter => true
  }

  def search_rides
    @departure_place = params[:departure_place]
    @departure_threshold = params[:departure_place_threshold].to_i
    @destination = params[:destination]
    @destination_threshold = params[:destination_threshold].to_i
    if params.has_key?(:departure_time)
      @departure_time = Time.zone.parse(params[:departure_time])
    end
    user = current_user
    @ride_type = params[:ride_type].to_i

    if @departure_place.nil?
      @departure_place = ""
    end
    if @destination.nil?
      @destination = ""
    end

    @rides = Ride.rides_nearby(@departure_place, @departure_threshold, @destination,
                              @destination_threshold, @departure_time, @ride_type).paginate(:page => params[:page], :per_page => 5)
    @rides_pic = Array.new

    @rides.each do |ride|
      if ride.ride_type != 0
        @rides_pic.push(get_picture(ride.destination_latitude, ride.destination_longitude))
      else
        @rides_pic.push("")
      end
    end

  end

  private

  def get_picture lat, lng
    lat = lat
    lng = lng
    options = {}

    points = Geocoder::Calculations.bounding_box([lat, lng], 10, { :unit => :mi })
    options.merge!({
                       :miny => points[0],
                       :minx => points[1],
                       :maxy => points[2],
                       :maxx => points[3]
                   })
    panoramio_options = DEFAULT_OPTIONS
    panoramio_options.merge!(options)
    response = RestClient.get URL, :params => panoramio_options
    if response.code == 200
      parse_data = JSON.parse(response.to_str)
      url = parse_data['photos'][0]['photo_file_url']
    else
      raise "Panoramio API error: #{response.code}. Response #{response.to_str}"
      url = ""
    end
    url
  end


end

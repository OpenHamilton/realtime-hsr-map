require './gtfs-realtime.pb.rb'
require 'open-uri'
require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/config_file'
require 'sinatra/json'

config_file 'config/config.yml'

class Route < ActiveRecord::Base
    self.primary_key = 'route_id'
    has_many :trips

    # See also: https://developers.google.com/transit/gtfs/reference#routes_fields
    # Columns (All string, unless otherwise specified):
    #
    # route_long_name       The name of the route (eg, DELAWARE)
    # route_type            Currently all 3 - Bus. Hopefully, one day, will include 0 - Light rail (and maybe even 7 - Funicular?)
    # route_text_color      A colour to use for text referring to this route
    # route_color           A colour to use for "branding" this route
    # agency_id             Currently just HSR
    # route_id              And internal ID of the route (eg, 2838)
    # route_url             Not used.
    # route_desc            Not used.
    # route_short_name      The route number (eg, 05)
end

get '/' do
  @mapboxId = settings.mapboxId
  erb :index
end

get '/buses' do
	url = 'http://opendata.hamilton.ca/GTFS-RT/GTFS_VehiclePositions.pb'
	data = FeedMessage.decode( open(url).read )
	bus_locations = []
	data.entity.each do |entity|
		route = Route.where( route_id: entity.vehicle.trip.route_id ).first

		bus_locations << {
			:bus_number => entity.vehicle.vehicle.label,
			:lat        => entity.vehicle.position.latitude,
			:lng        => entity.vehicle.position.longitude,
			:speed      => entity.vehicle.position.speed * 3.6,	# m/s to km/h
			:route_id   => route.route_id,
			:route_name => route.route_short_name + ' ' + route.route_long_name,
			:color      => route.route_color
		}
	end

	json bus_locations
end
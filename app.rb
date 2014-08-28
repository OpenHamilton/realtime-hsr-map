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

# Global variable because I'm an asshole and can't be arsed to learn how caching works in Sinatra right now.
@@routes = Hash.new

get '/' do
  @mapboxId = settings.mapboxId

  # Create route cache.
  routes = Route.all
  routes.each do |r|
  	@@routes[ r.route_id ] = r
  end

  erb :index
end

get '/buses' do
	vehicle_positions = get_vehicle_positions
	trip_updates      = get_trip_updates
	delays            = get_delays( trip_updates )
	bus_locations = []

	vehicle_positions.entity.each do |entity|
		route = @@routes[ entity.vehicle.trip.route_id ]

		trip_id = entity.vehicle.trip.trip_id
		delay   = delays[ trip_id ]
		color   = get_color( delay )
		
		if delay.nil?
			delay = '[unknown]'
		else
			delay = "#{( delay / 60.0 ).to_i} minutes"
		end

		bus_locations << {
			:bus_number => entity.vehicle.vehicle.label,
			:lat        => entity.vehicle.position.latitude,
			:lng        => entity.vehicle.position.longitude,
			:speed      => entity.vehicle.position.speed * 3.6,	# m/s to km/h
			:route_id   => route.route_id,
			:route_name => route.route_short_name + ' ' + route.route_long_name,
			:color      => color,
			:delay      => delay,
			:bearing    => entity.vehicle.position.bearing+90
		}
	end

	json bus_locations
end

def get_vehicle_positions
	url = 'http://opendata.hamilton.ca/GTFS-RT/GTFS_VehiclePositions.pb'
	data = FeedMessage.decode( open(url).read )
	return data
end

def get_trip_updates
	url = 'http://opendata.hamilton.ca/GTFS-RT/GTFS_TripUpdates.pb'
	data = FeedMessage.decode( open(url).read )
	return data
end

def get_delays( trip_updates )
	delays = Hash.new
	trip_updates.entity.each_with_index do |entity, i|
		next if entity.nil? or entity.trip_update.nil? or entity.trip_update.trip.nil? or entity.trip_update.stop_time_update.nil?
		trip_id = entity.trip_update.trip.trip_id

		min_update_index = 0
		min_update       = 1_000_000
		entity.trip_update.stop_time_update.each_with_index do |stop_time_update, j|
			next if ( stop_time_update.departure.nil? )

			time_remaining = Time.at( stop_time_update.departure.time ) - Time.now
			if time_remaining > 0 and time_remaining < min_update
				min_update = time_remaining
				min_update_index = j
			end
		end

		if entity.trip_update.stop_time_update[min_update_index].departure.nil?
			delays[ trip_id ] = nil
		else
			delays[ trip_id ] = entity.trip_update.stop_time_update[min_update_index].departure.delay
		end
	end
	return delays
end

def get_delay( trip_id, trip_updates )
	trip_updates.entity.each_with_index do |entity, i|
		next if entity.nil? or entity.trip_update.nil? or entity.trip_update.trip.nil? or entity.trip_update.stop_time_update.nil?
		next if entity.trip_update.trip.trip_id != trip_id

		min_update_index = 0
		min_update       = 1_000_000
		entity.trip_update.stop_time_update.each_with_index do |stop_time_update, j|
			next if ( stop_time_update.departure.nil? )

			time_remaining = Time.at( stop_time_update.departure.time ) - Time.now
			if time_remaining > 0 and time_remaining < min_update
				min_update = time_remaining
				min_update_index = j
			end
		end

		if entity.trip_update.stop_time_update[min_update_index].departure.nil?
			return 0
		else
			return entity.trip_update.stop_time_update[min_update_index].departure.delay
		end
	end
	return 0
end

def get_color( delay )
	return '000' if delay.nil?
	# Blue  - #0000FF - 10 minutes early
	#         #00FFFF
	# Green - #00FF00 - On time
	#         #FFFF00
	# Red   - #FF0000 - 10 minutes late
	if delay > 600
		delay = 600
	elsif delay < -600
		delay = -600
	end

	r = 0
	g = 0xFF
	b = 0

	# Red
	if delay > 0 and delay <= 300
		# Turn up the red.
		r = ( delay * ( 255.0/300.0 ) ).to_i
	elsif delay > 300
		# Turn down the green.
		r = 0xFF
		g = 255 - ( (delay-300) * ( 255.0/300.0 ) ).to_i
	elsif delay < -300
		# Turn down the green
		g = 255 - ( (delay.abs-300) * ( 255.0/300.0 ) ).to_i
		b = 0xFF
	else
		# Turn up the blue
		b = ( delay.abs * ( 255.0/300.0 ) ).to_i
	end
			
	return r.to_s(16).rjust(2, '0') + g.to_s(16).rjust(2, '0') + b.to_s(16).rjust(2, '0')
end

# Rakefile
require "./app"
require "csv"
require "json"
require "sinatra/activerecord/rake"

class CSVImporter
    def import_all!
        self.import 'routes.txt', 'Route'
    end

    def import(file_name, class_name)
        puts "Importing #{class_name}s..."
        klass = Object::const_get( class_name )
        klass.delete_all

        count = -1
        headings = []
        CSV.foreach("./gtfs/#{file_name}") do |row|
            count += 1
            if count == 0
                headings = row
                next
            end

            obj = klass.new
            row.each_with_index do |value, i|
                obj[ headings[i] ] = value
            end
            obj.save!
        end
        puts "#{count} #{class_name}s imported!"
    end
end

namespace :hsr do
    task :import do
        i = CSVImporter.new
        i.import_all!
        # first_row = true
        # headings = []
        # CSV.foreach('./gtfs/routes.txt') do |row|
        #     if first_row
        #         first_row = false
        #         headings = row
        #         next
        #     end

        #     route = Route.new
        #     row.each_with_index do |value, i|
        #         route[ headings[i] ] = value
        #     end
        #     route.save
        #     puts route
        # end
    end
end
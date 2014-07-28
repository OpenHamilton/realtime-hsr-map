# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140728190106) do

  create_table "routes", id: false, force: true do |t|
    t.string "route_long_name"
    t.string "route_type"
    t.string "route_text_color"
    t.string "route_color"
    t.string "agency_id"
    t.string "route_id"
    t.string "route_url"
    t.string "route_desc"
    t.string "route_short_name"
  end

end

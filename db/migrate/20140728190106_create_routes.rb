class CreateRoutes < ActiveRecord::Migration
  def change
  	create_table :routes, :id => false do |t|
  		t.string :route_long_name
  		t.string :route_type
  		t.string :route_text_color
  		t.string :route_color
  		t.string :agency_id
  		t.string :route_id
  		t.string :route_url
  		t.string :route_desc
  		t.string :route_short_name
  	end
  end
end

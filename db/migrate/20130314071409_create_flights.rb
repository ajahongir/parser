class CreateFlights < ActiveRecord::Migration
  def change
    create_table :flights do |t|
      t.string :name
      t.string :transport
      t.string :airline
      t.integer :departure_airport_id
      t.integer :arrival_airport_id
      t.datetime :departure_time
      t.datetime :arrival_time
      t.boolean :bussiness_space
      t.boolean :econom_space

      t.timestamps
    end
  end
end

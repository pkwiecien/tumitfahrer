class CreateRequests < ActiveRecord::Migration
  def change
    create_table :requests do |t|
      t.integer :ride_id
      t.integer :passenger_id
      t.string :requested_from
      t.string :request_to

      t.timestamps
    end
  end
end

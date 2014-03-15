class CreateRatings < ActiveRecord::Migration
  def change
    create_table :ratings do |t|
      t.integer :user_id
      t.integer :from_user
      t.integer :rating_type
      t.integer :ride_id

      t.timestamps
    end
  end
end

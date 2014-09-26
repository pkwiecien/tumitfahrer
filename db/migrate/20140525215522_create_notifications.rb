class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.integer :ride_id
      t.string :message_type
      t.datetime :date_time
      t.boolean :status

      t.timestamps
    end
  end
end

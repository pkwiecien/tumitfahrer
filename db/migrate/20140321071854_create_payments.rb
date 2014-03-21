class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.integer :from_user_id
      t.integer :to_user_id
      t.integer :ride_id
      t.float :amount

      t.timestamps
    end
  end
end

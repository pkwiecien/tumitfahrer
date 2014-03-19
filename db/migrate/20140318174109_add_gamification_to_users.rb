class AddGamificationToUsers < ActiveRecord::Migration
  def change
    add_column :users, :gamification, :boolean
  end
end

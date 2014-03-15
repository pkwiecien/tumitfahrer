class ChangeFormatInUsers < ActiveRecord::Migration
  def change
      change_column :users, :unbound_contributions, :float
  end
end

class Deletefieldsfromuser < ActiveRecord::Migration
  def change
    remove_column :users, :rank
    remove_column :users, :unbound_contributions
    remove_column :users, :exp
    remove_column :users, :gamification
  end
end

class RenameColumnInRatings < ActiveRecord::Migration
  def change
    rename_column :ratings, :from_user, :from_user_id
  end
end

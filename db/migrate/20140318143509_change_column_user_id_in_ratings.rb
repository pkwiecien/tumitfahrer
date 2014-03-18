class ChangeColumnUserIdInRatings < ActiveRecord::Migration
  def change
    rename_column :ratings, :user_id, :to_user_id
  end
end

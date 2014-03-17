class AddSeenToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :is_seen, :boolean
  end
end

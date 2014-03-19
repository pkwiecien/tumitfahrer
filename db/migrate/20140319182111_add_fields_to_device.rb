class AddFieldsToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :enabled, :boolean
    add_column :devices, :platform, :string
    rename_column :devices, :reg_id, :token
  end
end

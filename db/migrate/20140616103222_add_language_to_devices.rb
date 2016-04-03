class AddLanguageToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :language, :string
  end
end

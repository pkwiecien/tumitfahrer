class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.integer :phase
      t.float :fundings_target
      t.integer :owner_id
      t.string :description
      t.string :title
      t.datetime :date

      t.timestamps
    end
  end
end

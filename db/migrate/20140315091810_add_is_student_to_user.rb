class AddIsStudentToUser < ActiveRecord::Migration
  def change
    add_column :users, :is_student, :boolean
  end
end

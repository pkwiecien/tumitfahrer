class DeletefieldsfromrelationshipAndRequest < ActiveRecord::Migration
  def change
    remove_column :requests, :requested_from
    remove_column :requests, :request_to
  end
end

class AddClientIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :client_id, :string
  end
end

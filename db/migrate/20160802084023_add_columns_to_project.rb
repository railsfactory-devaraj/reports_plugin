class AddColumnsToProject < ActiveRecord::Migration
  def change
    add_column :projects, :sub_project_count, :integer
    add_column :projects, :client, :string
  end
end

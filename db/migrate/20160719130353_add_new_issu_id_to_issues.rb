class AddNewIssuIdToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :new_issue_id, :string
  end
end

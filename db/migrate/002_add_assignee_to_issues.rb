class AddAssigneeToIssues < ActiveRecord::Migration
  def self.up
    add_column :issues, :assignee, :string
    add_index :issues, :assignee
  end

  def self.down
    remove_index :issues, :assignee
    remove_column :issues, :assignee
  end
end

class CreateIssues < ActiveRecord::Migration
  def self.up
    create_table :issues do |t|
      t.string :key, :null => false
      t.string :status
      t.string :summary
      t.string :project
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
  end

  def self.down
    drop_table :issues
  end
end

class Issue < ActiveRecord::Base
  START_STATUSES = ['Assigned', 'Working on it', 'Resolved']
  END_STATUSES = ['Resolved']

  def self.track issue_data
    issue = self.find_or_initialize_by_key(issue_data[:key])

    if !issue.started_at && START_STATUSES.member?(issue_data[:status])
      issue_data[:started_at] = Time.now
    end

    if !issue.ended_at && END_STATUSES.member?(issue_data[:status])
      issue_data[:ended_at] = Time.now
    end

    issue.update_attributes(issue_data)
  end
end

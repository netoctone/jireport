class Issue < ActiveRecord::Base
  START_STATUSES = ['Assigned', 'Working on it', 'Resolved']
  END_STATUSES = ['Resolved']

  TRACK_STATUSES = ['New'] + START_STATUSES + END_STATUSES

  def self.track issue_data
    return unless TRACK_STATUSES.include?(issue_data[:status])

    issue = self.find_or_initialize_by_key(issue_data[:key])

    return if !issue.new_record? && issue.updated_at > issue_data[:updated_at]

    if !issue.started_at && START_STATUSES.member?(issue_data[:status])
      issue_data[:started_at] = issue_data[:updated_at]
    end

    if !issue.ended_at && END_STATUSES.member?(issue_data[:status])
      issue_data[:ended_at] = issue_data[:updated_at]
    end

    issue.update_attributes(issue_data)
  end

  def start_date
    started_at ? started_at.strftime("%D") : nil
  end

  def end_date
    ended_at ? ended_at.strftime("%D") : nil
  end

  STATUS_TO_PERCENT = {
    'Resolved' => '100',
    'Working on it' => '50'
  }

  def percent
    STATUS_TO_PERCENT[status]
  end

  STATUS_TO_DESCRIPTION = {
    'Resolved' => 'committed'
  }

  def description
    STATUS_TO_DESCRIPTION[status] || status
  end
end

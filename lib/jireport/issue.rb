class Issue < ActiveRecord::Base
  START_STATUSES = ['Assigned', 'Working on it', 'Resolved']
  END_STATUSES = ['Resolved']

  TRACK_STATUSES = ['New'] + START_STATUSES + END_STATUSES

  INIT_TRACK_ST = ['New', 'Assigned', 'Working on it']

  def self.track issue_data
    return unless TRACK_STATUSES.include?(issue_data[:status])

    issue = self.find_by_key(issue_data[:key])

    return unless INIT_TRACK_ST.include?(issue_data[:status]) unless issue

    if !issue.started_at && START_STATUSES.member?(issue_data[:status])
      issue_data[:started_at] = Time.now
    end

    if !issue.ended_at && END_STATUSES.member?(issue_data[:status])
      issue_data[:ended_at] = Time.now
    end

    issue ||= self.new

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
    'Resolved' => 'committed',
    'Working on it' => 'checked in'
  }

  def description
    STATUS_TO_DESCRIPTION[status] || status
  end
end

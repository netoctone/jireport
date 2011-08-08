require 'bundler/setup'
require 'ruby_extensions'
require 'active_record'
require 'active_support/time'
require 'jireport/issue'

module JiReport
  autoload :JiraFetch, 'jireport/jira_fetch'
  autoload :ExcelFormatter, 'jireport/excel_formatter'

  class Error < StandardError; end
  class NotAvailableError < Error; end
  class NotAuthenticatedError < Error; end
end

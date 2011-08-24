require 'bundler/setup'
require 'active_record'
require 'active_support/time'

require 'jireport/ruby_extensions'
require 'jireport/issue'

require 'open-uri'
require 'openssl'
require 'simple-rss'
require 'cgi'

module JiReport
  autoload :JiraRSSFetch, 'jireport/jira_rss_fetch'
  autoload :OdsTemplateFormatter, 'jireport/ods_template_formatter'

  class Error < StandardError; end
  class NotAvailableError < Error; end
  class NotAuthenticatedError < Error; end
end

require 'jira4r'

module JiReport

  class JiraFetch
    FIELDS = [ :key, :summary, :status, :project ]

    SSL_VERIFY_MODE = 'protocol.http.ssl_config.verify_mode'

    FIELD_NAME_TO_MAP_GETTER = {
      :status => 'getStatuses'
    }

    def initialize details
      @username = details[:login]
      @password = details[:password]
      @url = details[:url]
      @proxy = details[:proxy]

      begin
        @api = Jira4R::JiraTool.new(2, @url)
        @api.logger = details[:logger] || Logger.new('dev/null')
        @api.driver.options[SSL_VERIFY_MODE] = OpenSSL::SSL::VERIFY_NONE
        begin
          @api.driver.httpproxy = @proxy if @proxy
        rescue ArgumentError => e
          raise NotAvailableError, "Proxy '#@proxy' is unavailable"
        end
        @api.login(@username, @password)
      rescue SOAP::FaultError => e
        raise NotAuthenticatedError, 'Invalid username or password'
      rescue ::SocketError, HTTPClient::BadResponseError,
             OpenSSL::SSL::SSLError, Errno::ECONNREFUSED,
             SOAP::HTTPStreamError => e
        raise NotAvailableError, "Jira service '#@url' is unavailable"
      end

      @field_convert = {}
      FIELD_NAME_TO_MAP_GETTER.each do |name, getter|
        convert = {}
        @api.send(getter).each do |field|
          convert[field.id] = field.name
        end
        @field_convert[name] = convert
      end
    end

    LIMIT = 1000

    # @param options [Hash] -
    #   :updated_after [DateTime] - optional
    #   :assignee [String] - optional
    def fetch_issues options
      assignee = options[:assignee] || @username
      jql = "assignee = #{assignee}"
      if upd = options[:updated_after]
        jql << " AND updated >= '#{(upd-60).strftime('%Y-%m-%d %H:%M')}'"
      end
      @api.send('getIssuesFromJqlSearch', jql, LIMIT).map do |issue|
        data = {}
        FIELDS.each do |name|
          data[name] = meaningful_value(name, issue.send(name))
        end
        data[:assignee] = assignee
        data
      end
    end

    private
    def meaningful_value name, val
      FIELD_NAME_TO_MAP_GETTER[name] ? @field_convert[name][val] : val
    end

  end

end

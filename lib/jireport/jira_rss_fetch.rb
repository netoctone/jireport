module JiReport

  class JiraRSSFetch

    # params [Hash] -
    #   :url => [String]      - Jira server url
    #   :login => [String]    - Jira login
    #   :password => [String] - Jira password
    #   :proxy => [String]    - optional
    def initialize params
      @uri_name = "#{params[:url].chomp '/'}/plugins/servlet/streams?" \
                  "os_password=#{params[:password]}&" \
                  "os_username=#{params[:login]}"

      @uri_params = { :ssl_verify_mode => OpenSSL::SSL::VERIFY_NONE }
      @uri_params[:proxy] = params[:proxy] if params[:proxy]
    end

    DEFAULT_LIMIT = 30

    # user [String] - login of user, whose activity entries will be fetched
    # limit [String] - max number of rss entries
    def fetch user, limit=DEFAULT_LIMIT
      full_uri_name = "#{@uri_name}&filterUser=#{user}&maxResults=#{limit}"

      io = open(full_uri_name, @uri_params)

      begin
        block_given? ? yield(io) : io.read
      ensure
        io.close
      end
    end

    def fetch_changed_issues user, limit=DEFAULT_LIMIT
      fetch(user, limit){ |io| SimpleRSS.parse io }.entries.map{ |e|
        /&gt;.*?&gt;(.*?)&lt;.*?&gt;(.*?)&lt;.*?&gt;(.*)/ =~ e.title
        activity = $1.strip
        summary = $3.strip
        feed = {
          :key => $2.strip,
          :assignee => user
        }

        if activity.start_with? 'changed'
          /to (.*?) of$/ =~ activity
          feed[:status] = $1
        elsif activity.start_with? 'resolved'
          feed[:status] = 'Resolved'
        else
          next
        end

        feed[:summary] = CGI.unescape_html CGI.unescape_html summary[1...-1]
        feed[:updated_at] = e.updated
        feed
      }.compact
    end

  end

end

require 'google_spreadsheet'

module JiReport

  class GoogleSpreadsheets
    def initialize details={}
      @session = GoogleSpreadsheet.login(
        details[:login] || details['login'],
        details[:password] || details['password']
      )
    rescue SocketError, EOFError => e
      raise NotAvailableError, 'Google Spreadsheets API is not available'
    rescue GoogleSpreadsheet::AuthenticationError => e
      # not sure about that
      raise NotAuthenticatedError, "Invalid login or password"
    end

    # if report exist, it's save is forbidden
    def report_exist? name
      not @session.spreadsheets('title' => name).empty?
    end

    WorksheetConfig = begin
      short_report_columns = [
        {
          :source => [:acc, :fullname],
          :header_name => 'Name'
        },
        {
          :source => [:track, :key],
          :header_name => 'Task ID'
        },
        {
          :source => [:track, :status],
        }
      ]

      detailed = Array.new short_report_columns
      detailed[1...1] = [
        {
          :source => [:params, :nil],
          :header_name => ''
        }
      ]
      detailed[-1...-1] = [
        {
          :source => [:track, :summary],
          :header_name => 'Task Desc'
        },
        {
          :source => [:track, :started_at],
          :header_name => 'Start date'
        },
        {
          :source => [:track, :ended_at],
          :header_name => 'End date'
        },
        {
          :source => [:params, :nil],
          :header_name => 'Detailed task description',
        }
      ]
      detailed.push({
        :source => [:params, :comments],
        :header_name => 'Comments'
      })


      [
        {
          :title => 'Short report',
          :columns => short_report_columns
        },
        {
          :title => 'Detailed report',
          :columns => detailed
        }
      ]
    end

    def save_report name, tracks, params={}
      sheets = @session.spreadsheets('title' => name)
      raise Error, "report '#{name}' already exist" unless sheets.empty?

      sheet = @session.create_spreadsheet name

      WorksheetConfig.each do |config|
        ws = sheet.add_worksheet config[:title]
        config[:columns].each_with_index do |col_conf, i|
          ws[1, i+1] = col_conf[:header_name] || col_conf[:source][1].to_s
        end

        g_row = 2
        tracks.each do |acc, tracks|
          config[:columns].each_with_index do |col_conf, i|
            src = col_conf[:source]
            if src[0].eql? :acc
              ws[g_row, i+1] = build_value(acc, col_conf)
            elsif src[0].eql? :params
              ws[g_row, i+1] = params[src[1]]
            end
          end

          g_row += 1

          tracks.each do |track|
            config[:columns].each_with_index do |col_conf, i|
              if col_conf[:source][0].eql? :track
                ws[g_row, i+1] = build_value(track, col_conf)
              end
            end

            g_row += 1
          end

          g_row += 1
        end

        ws.save
      end
    rescue SocketError, EOFError => e # think
      raise NotAvailableError, 'Google Spreadsheets API is not available'
    end

    private

    def build_value obj, col_conf
      val = obj.send_chain(col_conf[:source].slice(1..-1))
      if map = col_conf[:map]
        val = map[val]
      end
      val
    end
  end

end

require 'spreadsheet'
require 'stringio'

module JiReport

  module ExcelFormatter
    HEADER_HEIGHT = 35
    ISSUE_HEIGHT = 30
    DEFAULT_WIDTH = 10

    COL_DEFAULT_FORMAT = Spreadsheet::Format.new :align => :justify

    HEADER_FORMAT = Spreadsheet::Format.new :bold => true,
                                            :color => :green,
                                            :align => :justify

    USER_FORMAT = Spreadsheet::Format.new :bold => true,
                                          :color => :red

    def self.generate file_path, metadata, data
      spread = Spreadsheet::Workbook.new

      metadata.each do |work_conf|
        g_row = 0
        ws = spread.create_worksheet(:name => work_conf[:title])

        row = ws.row(g_row)
        row.height = HEADER_HEIGHT
        row.default_format = HEADER_FORMAT
        next unless work_conf[:columns]
        work_conf[:columns].each_with_index do |col_conf, i|
          col = ws.column(i)
          col.width = col_conf[:width] || DEFAULT_WIDTH
          col.default_format = COL_DEFAULT_FORMAT
          row[i] = col_conf[:header] || col_conf[:source][1].to_s
        end

        g_row += 1

        data.each do |user, issues|
          row = ws.row(g_row)
          row.default_format = USER_FORMAT
          work_conf[:columns].each_with_index do |col_conf, i|
            src = col_conf[:source]
            if src && src[0].equal?(:user)
              row[i] = user.send(src[1])
            end
          end

          g_row += 1

          unless work_conf[:no_issue]
            issues.each do |issue|
              work_conf[:columns].each_with_index do |col_conf, i|
                row = ws.row(g_row)
                row.height = ISSUE_HEIGHT
                src = col_conf[:source]
                if src && src[0].equal?(:issue)
                  row[i] = issue.send(src[1])
                end
              end

              g_row += 1
            end
          end

          g_row += 1
        end
      end

      spread.write file_path
    end

  end

end

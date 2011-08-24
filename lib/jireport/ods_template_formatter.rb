require 'rubiod'
require 'stringio'
require 'fileutils'

module JiReport

  module OdsTemplateFormatter
    def self.generate template_path, file_path, metadata, data
      FileUtils.cp template_path, file_path

      spread = Rubiod::Spreadsheet.new file_path

      metadata.each do |work_conf|
        next unless work_conf[:columns]

        g_row = 0
        ws = spread[work_conf[:title]]

        row = ws[g_row]
        work_conf[:columns].each_with_index do |col_conf, i|
          row[i] = col_conf[:header] || col_conf[:source][1].to_s
        end

        g_row += 1

        data.each do |user, issues|
          row = ws[g_row]
          work_conf[:columns].each_with_index do |col_conf, i|
            src = col_conf[:source]
            if src && src[0].equal?(:user)
              row[i] = user.send(src[1])
            end
          end

          g_row += 1

          issues.each do |issue|
            ws.insert(g_row)
            row = ws[g_row]
            work_conf[:columns].each_with_index do |col_conf, i|
              src = col_conf[:source]
              if src && src[0].equal?(:issue)
                row[i] = issue.send(src[1])
              end
            end

            g_row += 1
          end

          g_row += 1
        end

        while ws[g_row, 0]
          2.times { ws.delete(g_row) }
        end
      end

      spread.save
    end

  end

end

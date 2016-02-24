class MapExportService < Struct.new(:controller, :map)
  def render_csv
    set_file_headers(:csv)
    set_streaming_headers

    @controller.response.status = 200
    @controller.response_body = csv_lines
  end

  def render_xls
    set_file_headers(:xls)
    set_streaming_headers

    @controller.response.status = 200
    @controller.response_body = xls_lines
  end

  def set_file_headers(type)
    file_name = "metamaps.cc.map.#{@map.id}.#{type}"
    content_type = type == :xls ? 'application/vnd.ms-excel' : 'text/csv'

    @controller.headers['Content-Type'] = content_type
    @controller.headers['Content-disposition'] = %Q'attachment; filename="#{filename}"'
  end

  def set_streaming_headers
    @controller.headers['X-Accel-Buffering'] = 'no'
    @controller.headers['Cache-Conttrol'] ||= 'no-cache'
    @controller.headers.delete('Content-Length')
  end

  def csv_lines
    Enumerator.new do |out|
      @map.to_spreadsheet.each do |row|
        out << CSV::Row.new(row)
      end
    end
  end

  def xls_lines
    Enumerator.new do |out|
      out << '<table><tbody>'
      @map.to_spreadsheet.each do |row|
        out << '<tr>'
        row.each do |field|
          out << "<td>#{field}</td>"
        end
        out << '</tr>'
      end
      out << '</tbody></table>'
    end
  end
end

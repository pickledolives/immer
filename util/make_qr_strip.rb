require 'json'
require 'rqrcode'

installation = ARGV[0]
data = JSON.parse(File.open("./installations/#{installation}/qr_codes.json").read)

qr_strip_html =
  '<div>' + data.map do |row|
    row.map do |record|
      qrcode = RQRCode::QRCode.new(record.to_json)
      '<svg>' +  qrcode.as_svg(
        offset: 0,
        color: '000',
        shape_rendering: 'crispEdges',
        module_size: 6,
        standalone: false
      ) + '</svg>'
    end.join
  end.join('</div><div>') + '</div>'

html_page = '<html><head><style type="text/css">svg { margin: 20px; width: 300px; height: 300px; }</style></head><body>' + qr_strip_html + '</body><html>'
File.open("./installations/#{installation}/qr_codes.html", 'w') { |f| f.puts html_page }

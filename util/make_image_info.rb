require 'erb'
require 'rqrcode'

# TODO: convert videos: ffmpeg -i xxx.mov xxx.mp4

API_HOST = 'http://127.0.0.1:5432'
MOCK_API_RESPONSE = {
  '0x1234567890' => { title: 'Hustle', artist: 'O.E.KH.Thamm', qr_code: 'XXX', price: '$1299.00' },
  '0x1234567891' => { title: 'Passion', artist: 'O.E.KH.Thamm', qr_code: 'XXX', price: '$1299.00' },
  '0x1234567892' => { title: 'Team', artist: 'O.E.KH.Thamm', qr_code: 'XXX', price: '$1299.00' },
  '0x1234567893' => { title: 'Vision', artist: 'O.E.KH.Thamm', qr_code: 'XXX', price: '$1299.00' }
}
installation_name = ARGV[0] || raise('no installation provided')
template = File.read('./screen_files/template.xhtml.erb')

Dir.foreach("./tmp/#{installation_name}/images/") do |filename|
  qr_code = RQRCode::QRCode.new("#{API_HOST}/info/#{art_piece_address}").as_svg(
    offset: 0,
    color: '000',
    shape_rendering: 'crispEdges',
    module_size: 6,
    standalone: false
  )
  info = MOCK_API_RESPONSE[art_piece_address]&.merge(qr_code: qr_code) || {}
  screen_file_html = ERB.new(template).result_with_hash(info: info)
  File.open("./tmp/#{installation_name}/media/#{filename.gsub(ext, '.xhtml')}", 'w') { |f| f.puts screen_file_html }
end

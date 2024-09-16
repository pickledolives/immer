require 'erb'
require 'rqrcode'

# TODO: convert videos: ffmpeg -i xxx.mov xxx.mp4

installation_name = ARGV[0] || raise('no installation provided')
template = File.read('./screen_files/template.xhtml.erb')

Dir.foreach("./tmp/#{installation_name}/images/") do |filename|
  next if filename == '.' or filename == '..'
  ext = File.extname(filename)
  art_piece_address = filename.split('.').first
  image_path = "./tmp/#{installation_name}/images/#{filename}"
  image_tag =
    case ext
    when '.svg' then inline_svg(File.open(image_path).read)
    when '.jpg', '.jpeg', '.gif', '.png' then '<img src="../images/' + filename + '"></img>'
    when '.mp4', '.ogg' then '<video loop="true" muted="true" autoplay="true"><source src="../images/' + filename + '" type="video/mp4"></source></video>'
    else raise("unsupported image file format '#{ext}' for #{filename}")
    end
  screen_file_html = ERB.new(template).result_with_hash(image_tag: image_tag)
  File.open("./tmp/#{installation_name}/media/#{filename.gsub(ext, '.xhtml')}", 'w') { |f| f.puts screen_file_html }
end

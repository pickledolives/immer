puts "Discover devices registered with IP addresses in your local WiFi:"
pp `arp -a`
puts "---"

puts "Discover audio devices currently linked with your laptop:"
pp `ffmpeg -f lavfi -i sine=r=44100 -f audiotoolbox -list_devices true -t 1ms - 2>&1 | grep AudioToolbox`
puts "---"

if File.exist?('../config/ha.yml')
  puts "Home Assistant registered Devices:"
  $ha = HomeAssistant.new
  $ha.discover_states
  $ha.discover_services
else
  puts "Home Assistant not configured, yet."
end

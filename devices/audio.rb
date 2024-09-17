require 'os'

class Audio < Device

  DISCOVER_CMD = 'ffmpeg -f lavfi -i sine=r=44100 -f audiotoolbox -list_devices true -t 1ms -'

  def initialize(args)
    super(args['avg_lag_ms'])
    @installation_name = args['installation_name']
    @device_index = find_index(args['device_name']) unless args['device_name'].nil?
  end

  # TODO: add flash vs loop option
  def play(conf)
    opts = ''
    opts << " -audio_device_index #{@device_index}" unless @device_index.nil?
    opts << " -t #{conf['duration_ms']}ms" unless conf['duration_ms'].nil?
    if !conf['duration_ms'].nil?
      fades = []
      fades << "afade=t=in:st=0:d=#{conf['fade_in_s']}" unless conf['fade_in_s'].nil?
      fades <<  "afade=t=out:st=#{(conf['duration_ms'].to_f / 1000).to_i - conf['fade_out_s'].to_i}:d=#{conf['fade_out_s']}" unless conf['fade_out_s'].nil?
      opts << " -af \"#{fades.join(',')}\"" if fades.any?
    end
    case
    when OS.mac? then `ffmpeg -hide_banner -loglevel error -i ./tmp/#{@installation_name}/media/#{conf['tune']} -f audiotoolbox #{opts} -`
    when OS.linux? then `mpg123 --timeout #{(conf['duration_ms'].to_f / 1000).round} ./tmp/#{@installation_name}/media/#{conf['tune']}` #TODO support multi audio devices
    end
  end

  def self.discover
    `#{DISCOVER_CMD} 2>&1 | grep AudioToolbox`
  end

  def find_index(name)
    `#{DISCOVER_CMD} 2>&1 | grep #{name}`.match(/\[(\d+)\]/)[1]
  end
end

# frozen_string_literal: true

require 'watir'
require 'uri/query_params'

# TODO: add flash vs loop option
# TODO: add muted option
class Screen < Device
  def initialize(args)
    super(args['avg_lag_ms'])
    @x_position = args['x_position'] || 0
    @padding_pc = args['padding_pc'] || 0
    @installation_name = args['installation_name']
  end

  def turn_on(conf = {})
    if @browser&.exist?
      @browser.goto(location(conf))
    else
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument("window-position=#{@x_position},0")
      options.add_argument('start-fullscreen')
      options.add_argument('autoplay')
      options.add_argument("app=#{location(conf)}")
      options.exclude_switches << "enable-automation"
      @browser = Watir::Browser.new(Selenium::WebDriver.for(:chrome, options: options))
    end
  end

  def turn_off(_conf = {})
    @browser&.close
  end

  private

  def location(conf)
    if conf['url']
      conf['url']
    elsif conf['file']
      params = URI::QueryParams.dump(
        conf.slice('background', 'info', 'info_show_ms').merge(
          'pad_pc' => conf['padding_pc'] || @padding_pc
        )
      )
      "file://#{Dir.pwd}/installations/#{@installation_name}/media/#{conf['file']}?#{params}"
    else
      raise 'exhibit not found'
    end
  end
end

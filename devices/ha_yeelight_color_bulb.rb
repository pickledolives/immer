# frozen_string_literal: true

require 'color'

class HaYeelightColorBulb < HaDevice
  ALLOWED_ATTRS = %w[rgb_color brightness_pct]
  
  def initialize(args)
    super(args)
    # @on, @h, @s, @l = TODO: fetch from lightbulb
    @brightness_pct = 100
    $ha.service_request('yeelight', 'set_mode', entity_id, { mode: 'rgb' })
    change_color('color' => 'white')
  end

  def turn_on(conf = {})
    if conf.key?('color')
      @r, @g, @b = calc_color(conf)
      conf.delete('color')
      conf['rgb_color'] = [@r, @g, @b]
    end
    if conf.key?('brightness_pct')
      @brightness_pct = conf['brightness_pct']
    end
    super(conf.slice(*ALLOWED_ATTRS))
    @on = true
  end

  def turn_off(conf = {})
    super({})
    @on = false
  end

  def flash_color(conf)
    init_off = !@on
    o_conf = { 'r' => @r, 'g' => @g, 'b' => @b }
    change_color(conf)
    sleep (conf['duration_ms'] || 0).to_f / 1000
    change_color(o_conf)
    turn_off if init_off
  end

  def flash_brightness(conf)
    init_off = !@on
    #e = conf['effect'] || 'smooth'
    #d = conf['fade_ms'] || 0
    service_request('turn_on', { 'brightness_pct' => @brightness_pct + (conf['by_pct'] || 0) })
    pp "sleep #{(conf['duration_ms'] || 0).to_f / 1000}"
    sleep (conf['duration_ms'] || 0).to_f / 1000
    service_request('turn_on', { 'brightness_pct' => @brightness_pct })
    turn_off if init_off
  end

  def change_color(conf)
    #e = conf['effect'] || 'smooth'
    #d = conf['fade_ms'] || 0
    @r, @g, @b = calc_color(conf)
    service_request('turn_on', { 'rgb_color' => [@r, @g, @b] })
    @on = true
  end

  private

  def calc_color(conf)
    if (name = conf['color'])
      rgb = Color::CSS[name].to_rgb
      [rgb.red.to_i, rgb.green.to_i, rgb.blue.to_i]
    else
      [conf['r'], conf['g'], conf['b']]
    end
  end
end

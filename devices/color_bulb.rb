# frozen_string_literal: true

class ColorBulb < Device
  def turn_on(_conf); raise(NotImplementedError); end
  def turn_off(_conf); raise(NotImplementedError); end
  def flash_color(_conf); raise(NotImplementedError); end
  def flash_brightness(_conf); raise(NotImplementedError); end
end

# frozen_string_literal: true

class QrCodeReader < Device

  def initialize(args)
    @cache_count = args['cache_count'] || 1
    @frequency = args['frequency'] || '0.25'
    @pid = nil
  end

  def turn_on(args = {})
    @pid = spawn("python3.12 drivers/qrcode-reader/qr-reader.py #{@cache_count} #{@frequency}")
  end

  def turn_off(args = {})
    `kill -9 #{@pid}`
  end

  # detect cameras and microphones
  # ffmpeg -f avfoundation -list_devices true -i "" 2>&1 | grep AVFoundation
end

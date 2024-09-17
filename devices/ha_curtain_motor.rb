class HaCurtainMotor < HaDevice

  def open_cover(_conf = {})
    service_request('open_cover')
  end

  def close_cover(_conf = {})
    service_request('close_cover')
  end

  def on(_conf = {}); end
  def off(_conf = {}); end
end

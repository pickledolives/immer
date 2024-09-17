class HaSwitch < HaDevice
  def on(_conf = {})
    service_request('turn_on')
  end

  def off(_conf = {})
    service_request('turn_off')
  end
end

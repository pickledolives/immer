# frozen_string_literal: true

class HaSwitch < HaDevice
  def turn_on(_conf = {})
    super({})
    pp ">>> FAN TURN ON!!!!"
  end

  def turn_off(_conf = {})
    super({})
  end
end

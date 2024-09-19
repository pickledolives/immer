# frozen_string_literal: true

class Hs100 < Plug
  def initialize(args)
    super('switch', args['entity_id'], args['avg_lag_ms'])
  end

  def plug_on(_conf)
    service_request('turn_on')
  end

  def plug_off(_conf)
    service_request('turn_off')
  end

  def self.discover
  end
end

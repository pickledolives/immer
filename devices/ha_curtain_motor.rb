# frozen_string_literal: true

class HaCurtainMotor < HaDevice

  def initialize(args)
    super(args)
    @open = $ha.states.detect { |r| r['entity_id'] == @entity_id }['state'] == 'open'
  end

  def toggle(_conf = {})
    @open ? close_cover : open_cover
    @open = !@open
  end

  def open_cover(_conf = {})
    service_request('open_cover')
  end

  def close_cover(_conf = {})
    service_request('close_cover')
  end
end

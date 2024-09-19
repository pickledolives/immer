# frozen_string_literal: true

class HaDevice < Device
  class NotImplementedError < StandardError; end 

  attr_reader :ha_domain, :entity_id, :avg_lag_ms

  def initialize(args)
    super(args['avg_lag_ms'])
    @ha_domain = args['ha_domain'] || args['entity_id'].split('.').first
    @entity_id = args['entity_id']
  end

  def service_request(ha_service, payload = {})
    $ha.service_request(@ha_domain, ha_service, @entity_id, payload)
  end

  def turn_on(conf = {})
    service_request('turn_on', conf)
  end

  def turn_off(conf = {})
    service_request('turn_off', conf)
  end

  def flash(conf)
    turn_on(conf)
    puts "HA Device Flash: #{(conf['duration_ms'] || 0).to_f / 1000}"
    sleep (conf['duration_ms'] || 0).to_f / 1000
    turn_off(conf)
  end

  # @return Hash config
  def self.detect(args); raise 'not implemented'; end

  # @return void
  def self.test; raise 'not implemented'; end

  # @return integer avg_lag_ms
  def self.benchmark_cmds(args); raise 'not implemented'; end
end

require 'rest-client'

class Device
  class NotImplementedError < StandardError; end 

  def initialize(avg_lag_ms)
    @avg_lag_ms = avg_lag_ms || 0
  end

  def on(conf = {}); end
  def off(conf = {}); end

  # @return Hash config
  def self.detect(args); raise 'not implemented'; end

  # @return void
  def self.test; raise 'not implemented'; end

  # @return integer avg_lag_ms
  def self.benchmark_cmds(args); raise 'not implemented'; end
end

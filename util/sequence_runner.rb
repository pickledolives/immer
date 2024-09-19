require 'yaml'
require 'thwait'
require_relative '../devices/list'

class SequenceRunner
  STEP_MS = ENV.fetch('STEP_MS', 100).to_i
  STEP_SECS = STEP_MS.to_f / 1000

  attr_reader :devices, :sensors, :sequence, :events

  def initialize(devices, sensors, sequence, events)
    @devices = devices
    @sensors = sensors
    @sequence = sequence
    @events = events
    @threads = []
    @loops = 
      case sequence['loops']
      when true then -1
      when nil, false then 1
      else sequence['loops'].to_i
      end
  end

  def start
    @devices.values.each(&:turn_off)
    @sensors.values.each(&:turn_on)
    @threads = setup_threads
    exec_device_actions(@sequence['start'])
    while @loops != 0 do
      start_ts = now()
      ms = 0
      while ms < @sequence['length_ms'] do
        (@threads[ms] || []).each(&:wakeup)
        correction = (now() - start_ts).to_f - (ms.to_f / 1000)
        ms += STEP_MS
        wait_ms = STEP_SECS - correction
        sleep(wait_ms >= 0 ? wait_ms : 0)
      end
      @threads.values.flatten.each { |t| t.exit if t.alive? }
      @loops -= 1
      if @loops == 0
        exec_device_actions(@sequence['end'])
      else
        @threads = setup_threads
      end
    end
  end

  def end
    @threads.values.flatten.each { |t| t.exit if t.alive? }
    sleep(1)
    exec_device_actions(@sequence['end'])
  end

  def now
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  def setup_threads
    s_threads = {}
    @sequence['sequence'].each do |mss, conf|
      mss = mss.is_a?(String) ? mss.split(',').map(&:to_i) : [mss]
      mss.each do |ms|
        conf.each do |device_names, action_conf|
          device_names = device_names.is_a?(String) ? device_names.split(',').map(&:to_s) : [device_names]
          device_names.each do |device_name|
            slot = ms - ((@devices[device_name].avg_lag_ms.to_f / STEP_MS).round * STEP_MS)
            slot = 0 if slot < 0
            s_threads[slot] ||= []
            s_threads[slot] << Thread.new {  Thread.stop; @devices[device_name].send(action_conf['cmd'], action_conf) }
          end
        end
      end
    end
    s_threads
  end

  def exec_device_actions(actions)
    (actions || {}).each do |device_names, action_conf|
      device_names = device_names.is_a?(String) ? device_names.split(',').map(&:to_s) : [device_names]
      device_names.each do |device_name|
        @devices[device_name.strip].send(action_conf['cmd'].strip, action_conf)
      end
    end
  end
end

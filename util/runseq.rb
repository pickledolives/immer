require 'yaml'
require 'thwait'
require_relative '../devices/list'

# TODO: CONFIG script: detect plugs, for each blink it and ask for name, save to yml. Then load here.
#IP `bash hs100.sh discover`.split.last

INSTALLATION_NAME = ARGV[0]
DEVICE_ENV = ARGV[1] || 'home'

SCRIPT = YAML.load(File.open("./tmp/#{INSTALLATION_NAME}/run.yml").read)['sequence_script']
DEVICES = YAML.load(File.open('./config/devices.yml').read)['devices'][DEVICE_ENV].map { |name, conf| [name, Object::const_get(conf['model_class']).new(conf.merge('installation_name' => INSTALLATION_NAME))] }.to_h
STEP_MS = ENV.fetch('STEP_MS', 100).to_i

STEP_SECS = STEP_MS.to_f / 1000
SCRIPT_LENGTH_SECS = SCRIPT['length_ms'].to_f / 1000

def now
  Process.clock_gettime(Process::CLOCK_MONOTONIC)
end

def setup_threads
  s_threads = {}
  SCRIPT['sequence'].each do |mss, conf|
    mss = mss.is_a?(String) ? mss.split(',').map(&:to_i) : [mss]
    mss.each do |ms|
      conf.each do |device_names, action_conf|
        device_names = device_names.is_a?(String) ? device_names.split(',').map(&:to_s) : [device_names]
        device_names.each do |device_name|
          slot = ms - ((DEVICES[device_name].avg_lag_ms.to_f / STEP_MS).round * STEP_MS)
          slot = 0 if slot < 0
          s_threads[slot] ||= []
          s_threads[slot] << Thread.new {  Thread.stop; DEVICES[device_name].send(action_conf['cmd'], action_conf) }
        end
      end
    end
  end
  s_threads
end

def run_now(seq)
  (seq || {}).each do |device_names, action_conf|
    device_names = device_names.is_a?(String) ? device_names.split(',').map(&:to_s) : [device_names]
    device_names.each do |device_name|
      DEVICES[device_name].send(action_conf['cmd'], action_conf)
    end
  end
end

threads = setup_threads
loops = 
  case SCRIPT['loops']
  when true then -1
  when nil, false then 1
  else SCRIPT['loops'].to_i
  end

at_exit do
  threads.values.flatten.each { |t| t.exit if t.alive? }
  sleep(1)
  run_now(SCRIPT['end'])
end

run_now(SCRIPT['start'])
while loops != 0 do
  start_ts = now()
  ms = 0
  while ms < SCRIPT['length_ms'] do
    (threads[ms] || []).each(&:wakeup)
    correction = (now() - start_ts).to_f - (ms.to_f / 1000)
    ms += STEP_MS
    sleep(STEP_SECS - correction)
  end
  threads.values.flatten.each { |t| t.exit if t.alive? }
  loops -= 1
  if loops == 0
    run_now(SCRIPT['end'])
  else
    threads = setup_threads 
  end
end

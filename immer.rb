# frozen_string_literal: true

require 'yaml'
require 'json'
require_relative './util/sequence_runner.rb'
require_relative './devices/list'

# ruby art_server.rb environment installation
DEVICE_ENV = ARGV[0]
INSTALLATION_NAMES = ARGV[1].split(',')

$ha = HomeAssistant.new
#$ha.discover_states
#$ha.discover_services

DEFAULT_DEVICES = {
  'terminal' => { 'model_class' => 'Terminal' },
  'this_screen' => { 'model_class' => 'Screen' },
  'this_speaker' => { 'model_class' => 'Audio', 'device_id' => 'BuiltInSpeakerDevice' }
}.freeze

@sequence_runners = {}
INSTALLATION_NAMES.each do |installation_name|
  device_defs = (YAML.load(File.open('./config/devices.yml').read)['devices'][DEVICE_ENV] || {}).freeze
  devices = device_defs.merge(DEFAULT_DEVICES).map do |name, conf|
    [name, Object::const_get(conf['model_class']).new(conf.merge('installation_name' => installation_name))]
  end.to_h.freeze
  sensor_defs = (YAML.load(File.open('./config/sensors.yml').read)['sensors'][DEVICE_ENV] || {}).freeze
  sensors = sensor_defs.map do |name, conf|
    [name, Object::const_get(conf['model_class']).new(conf.merge('installation_name' => installation_name))]
  end.to_h.freeze
  events = YAML.load(File.open("./installations/#{installation_name}/events.yml").read)['events'].freeze
  sequence = YAML.load(File.open("./installations/#{installation_name}/run.yml").read)['sequence_script']

  pp devices, sensors, sequence, events
  @sequence_runners[installation_name] = SequenceRunner.new(devices, sensors, sequence, events)
end

@current_sequence_runner = @sequence_runners.values.first
@current_sequence_runner.start

at_exit do
  @current_sequence_runner.end
end

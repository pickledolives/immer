# frozen_string_literal: true

require 'sinatra'
require 'yaml'
require 'json'
require_relative './util/sequence_runner.rb'
require_relative './devices/list'

set :bind, '0.0.0.0'

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
  @sequence_runners[installation_name] = SequenceRunner.new(devices, sensors, sequence, events)
end

$current_sequence_runner = @sequence_runners.values.first

def parse_body(request)
  case request.content_type
  when 'application/json' then JSON.parse(request.body.read)
  when 'application/yaml' then YAML.load(request.body.read)
  else {}
  end
rescue StandardError
  puts "ERROR in request body: #{request.body.read}"
  {}
end

post '/events/:sensor/:event_type' do
  payload = parse_body(request).merge(params.to_h)
  device_actions = $current_sequence_runner.events[payload['sensor']][payload['event_type']]
  device_actions.each do |device, opts|
    $current_sequence_runner.devices[device].send(opts['cmd'], opts.merge(payload))
  end
  pp payload
  status 201
end

post '/device_cmd' do
  payload = parse_body(request)
  $current_sequence_runner.devices[payload['device']].send(payload['action']['cmd'], payload['action'])
  status 201
rescue StandarError => error
  status 400
  { error: error.message }.to_json
end

get '/sequence/:installation_name' do
  payload = parse_body(request)
  $current_sequence_runner.end
  $current_sequence_runner = @sequence_runners[params['installation_name']]
  $current_sequence_runner.start
  status 201
rescue StandarError => error
  status 400
  { error: error.message }.to_json
end

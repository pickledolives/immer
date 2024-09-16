require 'sinatra'
require 'yaml'
require 'json'
require_relative './devices/list'

set :bind, '0.0.0.0'

$ha = HomeAssistant.new

DEFAULT_DEVICES = {
  'this_screen' => { 'model_class' => 'Screen' },
  'terminal' => { 'model_class' => 'Terminal' },
}.freeze
INSTALLATION_NAME = ARGV[0]
DEVICE_ENV = ARGV[1] || 'home'
DEVICE_DEFS = YAML.load(File.open('./config/devices.yml').read)['devices'][DEVICE_ENV].freeze
DEVICES = DEVICE_DEFS.merge(DEFAULT_DEVICES).map do |name, conf|
  [name, Object::const_get(conf['model_class']).new(conf.merge('installation_name' => INSTALLATION_NAME))]
end.to_h.freeze
EVENTS = YAML.load(File.open("./tmp/#{INSTALLATION_NAME}/events.yml").read)['events'].freeze

#$ha.discover
DEVICES.values.each(&:off)

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
  device_actions = EVENTS[payload['sensor']][payload['event_type']]
  device_actions.each do |device, opts|
    DEVICES[device].send(opts['cmd'], opts.merge(payload))
  end
  pp payload
  status 201
end

post '/device_cmd' do
  payload = parse_body(request)
  DEVICES[payload['device']].send(payload['action']['cmd'], payload['action'])
  status 201
rescue StandarError => error
  status 400
  { error: error.message }.to_json
end

post '/sequence' do
  payload = parse_body(request)
  status 201
rescue StandarError => error
  status 400
  { error: error.message }.to_json
end

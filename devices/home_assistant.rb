require 'rest-client'
require 'json'
require 'yaml'

class HomeAssistant
  HA_CONFIG = YAML.load(File.open('./config/ha.yml').read)['ha'].freeze
  HA_AUTH = {
    'Content-Type' => 'application/json',
    'Authorization' => "Bearer #{HA_CONFIG['token']}"
  }.freeze
  HA_IGNORE_DOMAINS = %w[person update zone].freeze

  def initialize
    @ha_ip = `arp -a | grep #{HA_CONFIG['mac']}`[/\(.*?\)/][1..-2]
  end

  def service_request(ha_domain, ha_service, entity_id, payload = {})
    pp "http://#{@ha_ip}:8123/api/services/#{ha_domain}/#{ha_service}", payload.merge(entity_id: entity_id).to_json
    RestClient.post("http://#{@ha_ip}:8123/api/services/#{ha_domain}/#{ha_service}", payload.merge(entity_id: entity_id).to_json, HA_AUTH) 
  end

  def discover
    puts "API States:"
    pp JSON.parse(RestClient.get("http://#{@ha_ip}:8123/api/states", HA_AUTH).body).reject { |r| HA_IGNORE_DOMAINS.any? { |d| r['entity_id'].start_with?(d) } }
    puts "---"
    puts "API Services:"
    pp JSON.parse(RestClient.get("http://#{@ha_ip}:8123/api/services", HA_AUTH).body)
    puts "---"
  end
end

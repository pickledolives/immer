# frozen_string_literal: true

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

  attr_reader :states, :services

  def initialize
    @ha_ip = ENV.fetch('HA_IP' ,`arp -a | grep #{HA_CONFIG['mac']}`[/\(.*?\)/][1..-2])
    @states = JSON.parse(RestClient.get("http://#{@ha_ip}:8123/api/states", HA_AUTH).body).reject { |r| HA_IGNORE_DOMAINS.any? { |d| r['entity_id'].start_with?(d) } }
    @services = JSON.parse(RestClient.get("http://#{@ha_ip}:8123/api/services", HA_AUTH).body)
    #pp @states
    #pp @services
  end

  def service_request(ha_domain, ha_service, entity_id, payload = {})
    pp "http://#{@ha_ip}:8123/api/services/#{ha_domain}/#{ha_service}", payload.merge(entity_id: entity_id).to_json
    RestClient.post("http://#{@ha_ip}:8123/api/services/#{ha_domain}/#{ha_service}", payload.merge(entity_id: entity_id).to_json, HA_AUTH) 
  end

  def discover_states
    puts "API States:"
    pp @states
    puts "---"
  end

  def discover_services
    puts "API Services:"
    pp @services
    puts "---"
  end
end

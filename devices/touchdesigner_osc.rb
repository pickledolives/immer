# frozen_string_literal: true

require 'osc-ruby'

class TouchdesignerOsc < Device

  def initialize(args)
    super
    @client = OSC::Client.new(args['ip'], args['port'])
    @project_name = args['project_name']
    @connector_name = args['connector_name']
  end

  def send_chop(args = {})
    @client.send(OSC::Message.new("/#{args['project_name'] || @project_name}/#{args['connector_name'] || @connector_name}", args['binary'].to_s))
  end

  def send_dat(args = {})
    @client.send(OSC::Message.new("/#{args['project_name'] || @project_name}/#{args['connector_name'] || @connector_name}", args['message'].to_s))
  end
end

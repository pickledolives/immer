# frozen_string_literal: true

class Terminal < Device
  def initialze(args)
    @installation_name = args['installation_name']
  end

  def execute(args)
    pp `cd ./installations/#{@installation_name}/scripts/ && #{args['script']}`
  end
end

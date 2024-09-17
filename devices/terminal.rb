class Terminal < Device
  def initialze(args)
  end

  def execute(args)
    pp `cd ./tmp/device_test/event_scripts/ && #{args['script']}`
  end
end

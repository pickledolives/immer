class Plug < HaDevice
  def plug_on; raise(NotImplementedError); end
  def plug_off; raise(NotImplementedError); end

  def plug_flash(conf)
    plug_on(conf)
    sleep (conf['duration_ms'] || 0).to_f / 1000
    plug_off(conf)
  end
end

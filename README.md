# Immer - Immersive Art Installations

But:

- Supermarket Hardware instead of professional expert equipment.
- Mobile and Reproducible instead of local one-off setups.
- Open Source and No-Code instead of expensive expert software.

Read more on [immerart.org](https://immerart.org).

## Installation (Mac OS)

Right now we only support MacOS but we will add support for more operating systems.

Make sure a Chrome or Chromium browser is installed.

Make sure Homebrew is installed.

Install Ruby 3.0.5. Check [this blog post](https://www.moncefbelyamani.com/how-to-install-xcode-homebrew-git-rvm-ruby-on-mac/)

```
brew install chruby ruby-install 
ruby-install ruby-3.0.5
```

Follow all the instructions, e.g. in case you'll have to add it to your CLI path.

### Install Browser library, audio, QR code reader

```
brew install chromedriver ffmpeg python@3.12 zbar
pip3 install pyzbar --break-system-packages
pip3 install pyzbar[scripts] --break-system-packages
pip3 install numpy --break-system-packages
pip3 install imutils --break-system-packages
pip3 install opencv-python --break-system-packages
pip3 install requests --break-system-packages
```

## Configure Immersive Art Installations

An experience may run on many sets of hardware called environments. E.g. a home environment, an atelier one, a gallery one, and many customer environments. To enable that define multiple environments with identically named devices that will have varying local device identifiers.

Similarly, many immersive art installations, that we sometimes call experiences, may run in the same environment. E.g. a wildflower experience and a mountain-top experience running in the same home environment using the same hardware.

Ultimately, you will start Immer providing as parameters a fixed environment and a (soon-to-be) changeable initial experience to load.

### Configure Home Assistant

```yml
# ./config/ha.yml

ha:
  mac: 'xxx' # Home Assistant MAC address / device identifier as found in your Home Assistant UI
  token: 'xxx' # Home Assistant security token as found in your Home Assistant UI 
```

### Configure devices to be used

By default the named devices "this_screen" and "this_speaker" of your current laptop are made available.

Discover accessible devices: `ruby ./util/discover_devices.rb`

```yml
# ./config/devices.yml

devices:
  home: # name your environment
    fan: # name your device
      model_class: HaSwitch # found in ./devices/*
      entity_id: switch.plug_jenny # found in the Home Assistant UI
    another_device:
      # ...
  another_environment:
    # ...
```

### Configure sensors to listen to

```yml
# ./config/sensors.yml

sensors:
  home: # name your environment
    qr_code_reader: # name your sensor
      model_class: QrCodeReader # found in ./devices/*
    another_device:
      # ...
  another_environment:
    # ...
```

### Configure immersive art installation experiences

```
# Create a new experience
cp -R ./installations/template/ ./installations/<MY_INSTALLATION_NAME>
```

- Put videos and other media directly viewable in a web browser into the media folder.
- Put images and other media that requires resizing into the images folder and run the according script from the ./util/ folder to embed it into a web page viewable in a web browser.
- Put custom code scripts into the scripts folder. A default device "terminal" with cmd "execute" allows you to start them locally.

#### Configure a set of sequences (WIP: rn only one sequence is possible)

Configure at which point in time (currently always in milliseconds) within the experience which device shall perform which action or "cmd" (short for command).

```yml
# ./<MY_INSTALLATION_NAME>/sequences.yml

sequence_script:
  loops: true # if true will loop this sequence until the process receives an exit signal
  loops_pause_ms: 1000
  length_ms: 45000
  start: # set the initial state of the environment before starting the experience
    this_screen: # device name as in ./config/devices.yml or the default devices
      cmd: turn_on # device action or command specific to the device type
      file: sonar.xhtml # a parameter custom to the specific device action
      another_parameter: "..."
    another_device:
      # ...
  end: # set the final state of the environment after stopping the experience
    gold_bulb: # device name as in ./config/devices.yml or the default devices
      cmd: turn_off # device action or command specific to the device type
    another_device:
      # ...
  sequence: # a sequence to run once or many times
    500: # milliseconds after experience start at which to perform the following
      tv_speaker: # device name as in ./config/devices.yml or the default devices
        cmd: play # device action or command specific to the device type
        tune: underwater.mp3 # a parameter custom to the specific device action
        duration_ms: 45000 # a parameter custom to the specific device action
        another_parameter: "..."
      another_device:
        # ...
    another_ms_mark:
      # ...
```

#### Configure a set of responses to sensor events

WIP: Rn only immediate device actions can be configured in response to events. The near term goal is to instead start a sequence as defined in `./<MY_INSTALLATION_NAME>/sequences.yml`.

```yml
events:
  btn_sasha: # sensor name as configured in ./config/sensors.yml
    press: # event name custom to the sensor
      gold_bulb: # # device name as in ./config/devices.yml or the default devices
        cmd: flash_color # device action or command specific to the device type
        color: blue # a parameter custom to the specific device action
        duration_ms: 2000 # a parameter custom to the specific device action
        another_parameter: "..."
      another_device:
        # ...
    another_event_name:
      # ...
  another_sensor:
    # ...
```

## Run your immersive art experience

Start the Ruby script `immer.rb` with paramaters `environment` and `installation_name`.

```
ruby immer.rb home demo
```

## Roadmap

WARNING: This project is in very much work in progress. There is a long list of TODOs on our road to an initial stable version.

- [ ] Refactor: run.yml to sequences.yml, cmd option to action
- [ ] Start Home Assistant connector only if necessary
- [ ] Create a demo experience without Home Assistant
- [ ] Make immer run the main experience and the server listening for events run at the same time communicating with each other
- [ ] Fix shutdown of an experience at application exit
- [ ] Catch configuration errors at startup like invalid device names, action names, etc
- [ ] Make switching experiences work on-the-fly
- [ ] Provide a basic intranet web interface for listing experiences and switching them
- [ ] Replace Screen device definition `x_position: 2000px` with `position: left`
- [ ] Allow multiple layers for screen media and transitions between them. Allow events to trigger layer switches.
- [ ] Detect and store laptop IP to remove option from TouchDesginer definitions

Please create GitHub issues for further bugs, feature requests, etc. Be nice at all times and to everyone.

## License

Distributed under the MIT License. See LICENSE.txt for more information.

## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are greatly appreciated.

If you have a suggestion that would make this better, please fork the repo and create a pull request. You can also simply open an issue with the tag "enhancement". Don't forget to give the project a star! Thanks again!

1. Fork the Project
1. Create your Feature Branch (git checkout -b feature/AmazingFeature)
1. Commit your Changes (git commit -m 'Add some AmazingFeature')
1. Push to the Branch (git push origin feature/AmazingFeature)
1. Open a Pull Request

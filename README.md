# RUNSEQ-IOT runs a sequence of home IoT commands

The sequence can easily be scripted in a human readable YAML config file by configuring at what particular time which devices are supposed to do something.

This repo collects home IoT devices that have been made controllable from your computer by design, by reverse engineering or other forms of hacking.

# Installation requirements

Right now we only support MacOS but will add more operating systems.

Make sure Chrome or Chromium browser is installed.

## Mac OSX

Make sure Homebrew is installed.

Install Ruby 3.0.5

```
brew install chruby ruby-3.0.5 # TODO Check!
# set as default Ruby
```

### Screen and Audio, QR code reader
```
brew install chromedriver ffmpeg python@3.12 zbar
pip3 install pyzbar --break-system-packages
pip3 install pyzbar[scripts] --break-system-packages
pip3 install numpy --break-system-packages
pip3 install imutils --break-system-packages
pip3 install opencv-python --break-system-packages
pip3 install requests --break-system-packages
```

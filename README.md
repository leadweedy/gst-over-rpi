# gst-over-rpi
Passes a simple camera feed remotely over UDP on a local network using [GStreamer](https://gstreamer.freedesktop.org/). Built for and tested on Raspberry Pi hardware. 

`./run-gst.sh`
```
Usage:
  run-gst.sh [OPTION...]

Help Options:
  -h                      Show help options

Application Options:
  -i <#.#.#.#>            IP address of the recieving computer
  -p <#>                  Port number [default:8080]
  -v </dev/video#>        Video source, e.g. /dev/video0
  -f </file/path>         Enables streaming from a video file
  -F <h264 or MJPG>       Select stream format [default:MJPG]
  -e <CPU or GPU>         Chooses between vaapi (GPU) or software (CPU) encoding,
                          only valid for h264 [default:CPU]
```
`./sink-gst.sh`
```
Usage:
  sink-gst.sh [OPTION...]

Help Options:
  -h                      Show help options

Application Options:
  -i <#.#.#.#>            IP address of the recieving computer
  -p <#>                  Port number [default:8080]
  -F <h264 or MJPG>       Select stream format [default:MJPG]
  -c                      Enables clock overlay [default:off]
```


## Hardware Setup

Flash Raspberry Pi OS to a microSD card or USB drive using [RPI Imager](https://www.raspberrypi.com/software/). The Lite version of the OS is recommmended, as no graphical interface will be needed. Before flashing, press `Ctrl+Shift+X` to open the advanced settings of the Imager. Enable `SSH` and set the hostname to something memorable, such as `ebay.local`.

![RPi wiring diagram](https://github.com/leadweedy/gst-over-rpi/blob/main/images/gst%20wiring%20diagram.png?raw=true)

Port [1] on the Pi Zero provides data+power, Port [2] provides power only. Connect the USB cable from Port [1] to the main Pi. Connect the Pi to the topside computer using ethernet. 

The Pi Zero (with the attached camera) runs the [showmewebcam](https://github.com/showmewebcam/showmewebcam) software that allows it to function as a configurable webcam device.

## SSH into RPi
Ensure the topside computer has a functioning mDNS. The Pi is setup with user `pi` and hostname `ebay.local`. SSH into the Pi by running `ssh pi@ebay.local` (Linux) or using [PuTTY](https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html) (Windows). 

## First Time Setup
Ensure the system is up to date and has all the required packages installed to run the gstreamer script. 

`sudo apt update`

`sudo apt full-upgrade`

`sudo apt install git`

`sudo apt install v4l-utils`

`sudo apt install libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgstreamer-plugins-bad1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-plugins-ugly gstreamer1.0-libav gstreamer1.0-tools gstreamer1.0-x gstreamer1.0-alsa gstreamer1.0-gl gstreamer1.0-gtk3 gstreamer1.0-pulseaudio` [[1]](https://gstreamer.freedesktop.org/documentation/installing/on-linux.html?gi-language=c#install-gstreamer-on-ubuntu-or-debian)

Check that the camera(s) are properly connected by running `v4l2-ctl --list-devices`. The camera should show up as `UVC Camera Raspberry Pi` or something similar. It will also provide a path to access the camera in the form of `/dev/video#`.

Run `v4l2-ctl --list-formats-ext -d /dev/video#` to check the possible resolutions. 

## Downloading the Code
Download these files to the RPi (while it is connected to the internet) by running

`git clone https://github.com/leadweedy/gst-over-rpi.git`.

Then move into the directory with the files and ensure they are all executable:

`cd gst-over-rpi/`

`chmod +x ./*`

Edit the source file with the IP address of the **Topside Computer** or pass the IP address as an argument using the `-i` flag. You can get the IP address of the topside computer by running `ip a` (Linux) or `ifconfig` (Windows) and looking for the IP of the ethernet connection.
    
    
On the host computer, do the same and run 

`git clone https://github.com/leadweedy/gst-over-rpi.git`

`cd gst-over-rpi/`

`chmod +x ./*`

To update, delete the directory and redownload it using the `git clone` command.

## Running the Code
On the RPi: run `./run-gst.sh` with the appropriate flags.

On the host computer: run `./sink-gst.sh` also with appropriate flags

## Troubleshooting
- MAKE SURE PORTS ARE OPEN
- IP addresses are both pointing to topside computer
- The RPi is not discoverable over UCLA Wifi or eduroam

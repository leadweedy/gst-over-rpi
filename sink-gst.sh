#!/bin/bash

# set internal IP of platform
IP=192.168.0.230
PORT=8080


CAPS="application/x-rtp,media=(string)video,encoding-name=(string)H264,clock-rate=(int)90000,payload=96" 
FPS=30


# adds input flag for port number
while getopts :p: option
do
    case "$option" in
    p)
         PORT=$OPTARG
         ;;
    *)
        echo "Hmm, an invalid option was received. -p requires an argument."
        echo "Here's the usage statement:"
        echo ""
        displayTpUsageStatement
        return
        ;;
        esac
done


#rtpjitterbuffer

## ENCODER=vaapi
# gst-launch-1.0 -v -e udpsrc uri=udp://$IP:$PORT caps=$CAPS ! \
# rtph264depay ! queue ! avdec_h264 ! xvimagesink sync=false


## ENCODER=h264
gst-launch-1.0 -v -e udpsrc uri=udp://$IP:$PORT caps=$CAPS ! \
rtpjitterbuffer ! rtph264depay ! queue ! decodebin ! \
videoconvert ! videoscale ! autovideosink


## MJPG
# gst-launch-1.0 -v -e udpsrc uri=udp://$IP:$PORT ! \
# application/x-rtp,encoding-name=JPEG,payload=26 ! rtpjpegdepay ! jpegdec ! autovideosink

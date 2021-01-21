#!/bin/bash

# set internal IP of platform
IP=192.168.0.230
PORT=8080
VIDEO=/dev/video0

WIDTH_IN=640
HEIGHT_IN=480
FPS_IN=30

WIDTH_OUT=960
HEIGHT_OUT=540
FPS_OUT=30


# ENCODER=vaapih264enc
ENCODER='x264enc tune=zerolatency qp-min=18 speed-preset=superfast'
PAYLOAD=rtph264pay
FORMAT=YUY2
SOURCE="v4l2src device"
EXTRA=""
CAPS="video/x-raw,width=$WIDTH_IN,height=$HEIGHT_IN,format=$FORMAT,framerate=$FPS_IN/1"
RESCALE=" ! video/x-raw,width=$WIDTH_OUT,height=$HEIGHT_OUT,framerate=$FPS_OUT/1 "


# adds input flag for port number
while getopts :i:p:v:f option
do
    case "$option" in
    i)
         IP=$OPTARG
         ;;
    p)
         PORT=$OPTARG
         ;;
    v)
         VIDEO=$OPTARG
         ;;
    f)
         SOURCE="multifilesrc location"
         EXTRA="decodebin"
         CAPS=""
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



# for h264 streams
gst-launch-1.0 -v -e $SOURCE="$VIDEO" ! $EXTRA $CAPS ! \
    videoscale $RESCALE ! videoconvert ! clockoverlay ! \
    queue ! $ENCODER ! $PAYLOAD ! \
    udpsink host=$IP port=$PORT



## MJPG stream (WIP)
# gst-launch-1.0 -v -e v4l2src device=/dev/video$VIDEO num-buffers=800 do-timestamp=true ! \
#     image/jpeg,width=$WIDTH, height=$HEIGHT, format=$FORMAT, framerate=$FPS/1 !\
#     rtpjpegpay ! queue ! \
#     udpsink host=$IP port=$PORT

#!/bin/bash

# set internal IP of platform
IP=192.168.0.230
PORT=8080
VIDEO=/dev/video0

#desired resolution of video stream from camera
#must be explicitly supported or pipeline fails
WIDTH_IN=640
HEIGHT_IN=480
FPS_IN=30

#resolution to rescale to
#any values are okay
WIDTH_OUT=720
HEIGHT_OUT=540
FPS_OUT=30

#choose an h264 encoder
#vaapi = GPU hardware accelerated
#x264 = cpu/software encoding

# ENCODER=vaapih264enc
ENCODER='x264enc tune=zerolatency qp-min=18 speed-preset=superfast'

#payload has to match encoder
PAYLOAD=rtph264pay

#format depends on what the camera outputs
FORMAT=YUY2

#used to ingest a video source (e.g. webcam)
SOURCE="v4l2src device"

EXTRA=""

#explicity sets the capabilites of the source device,
#helpful when it outputs multiple resolutions/formats
CAPS="video/x-raw,width=$WIDTH_IN,height=$HEIGHT_IN,format=$FORMAT,framerate=$FPS_IN/1"

#passed to videoscale module to resize the stream w/ bilinear filter
RESCALE=" ! video/x-raw,width=$WIDTH_OUT,height=$HEIGHT_OUT,framerate=$FPS_OUT/1 "


# adds input flags for more options
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



#udp is used over tcp for latency. udp is allowed to drop packets. if tcp falls behind,
#it tries to catch up and the stream lags behind

#clockoverlay adds timestamp to corner of video

# PIPELINE = raw video source -> scale/convert/overlays -> encode video -> pack into payload -> send to sink


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

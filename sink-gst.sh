#!/bin/bash

# set internal IP of platform
IP=192.168.1.102
PORT=8080

#resolution to rescale to
#any values are okay
WIDTH_OUT=800
HEIGHT_OUT=600



## DEFAULTS

CAPS="application/x-rtp,media=(string)video,encoding-name=(string)H264,clock-rate=(int)90000,payload=96"

#passed to videoscale module to resize the stream w/ bilinear filter
RESCALE=",width=$WIDTH_OUT,height=$HEIGHT_OUT"

FORMAT=h264

#clockoverlay adds timestamp to corner of video
# default = off
CLOCK=






# adds input flags for more options
while getopts :p:F:c option
do
    case "$option" in
    i)
         IP=$OPTARG
         ;;
    p)
         PORT=$OPTARG
         ;;
    F)
         FORMAT=$OPTARG
         ;;
    c)
         CLOCK="clockoverlay !"
         ;;
    *)
        echo "Usage:"
        echo "  sink-gst.sh [OPTION...]"
        echo ""
        echo "Help Options:"
        echo "  -h                      Show help options"
        echo ""
        echo "Application Options:"
        echo "  -i <#.#.#.#>            IP address of the recieving computer"
        echo "  -p <#>                  Port number [default:8080]"
        echo "  -F <h264 or MJPG>       Select stream format [default:h264]"
        echo "  -c                      Enables clock overlay [default:off]"
        echo ""
        exit
        ;;
        esac
done



# PIPELINE = recieve video srouce -> decode video -> convert back into raw video -> rescale/overlays -> display



## video sink for any h264 encoder
if [ "$FORMAT" = 'h264' ]; then
    gst-launch-1.0 -v -e udpsrc uri=udp://$IP:$PORT caps=$CAPS ! \
    rtph264depay ! queue ! avdec_h264 ! \
    videoconvert ! videoscale ! video/x-raw $RESCALE ! $CLOCK \
    autovideosink





## ENCODER=vaapi
# gst-launch-1.0 -v -e udpsrc uri=udp://$IP:$PORT caps=$CAPS ! \
# rtph264depay ! queue ! avdec_h264 ! xvimagesink sync=false

## ENCODER=h264
# gst-launch-1.0 -v -e udpsrc uri=udp://$IP:$PORT caps=$CAPS ! \
# rtph264depay ! queue ! decodebin ! \
# videoconvert ! videoscale ! autovideosink


## MJPG
elif [ "$FORMAT" = 'MJPG' ]; then
    gst-launch-1.0 -v -e udpsrc uri=udp://$IP:$PORT ! \
    application/x-rtp,encoding-name=JPEG,payload=26 ! rtpjpegdepay ! \
    jpegdec ! videoconvert ! videoscale ! video/x-raw $RESCALE ! $CLOCK  \
    autovideosink
        
else
    echo "Wrong stream format"
fi


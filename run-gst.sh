#!/bin/bash

# ip address of topside computer
IP=192.168.1.102
PORT=8080
VIDEO=/dev/video0

# desired resolution of video stream from camera
# must be explicitly supported or pipeline fails
# run ``v4l2-ctl --list-formats-ext /dev/video0`` to get list of resolutions
WIDTH_IN=640
HEIGHT_IN=480
FPS_IN=30




## DEFAULTS

# h264 encoder defaults to software encoding
H264=x264enc

# streaming format defaults to MJPG
FORMAT=MJPG

#format depends on what the camera outputs
FORMAT=YUY2

#used to ingest a video source (e.g. webcam)
SOURCE="v4l2src device"

# extra arguments, unused
EXTRA=""

#explicity sets the capabilites of the source device,
#helpful when it outputs multiple resolutions/formats
CAPS=",width=$WIDTH_IN,height=$HEIGHT_IN,format=$FORMAT,framerate=$FPS_IN/1"


# adds input flags for more options
while getopts :i:p:v:F:e:f option
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
    F)
         FORMAT=$OPTARG
         ;;
    e)
         H264=$OPTARG
         ;;
    *)
        echo "Usage:"
        echo "  run-gst.sh [OPTION...]"
        echo ""
        echo "Help Options:"
        echo "  -h                      Show help options"
        echo ""
        echo "Application Options:"
        echo "  -i <#.#.#.#>            IP address of the recieving computer"
        echo "  -p <#>                  Port number [default:8080]"
        echo "  -v </dev/video#>        Video source, e.g. /dev/video0"
        echo "  -f </file/path>         Enables streaming from a video file"
        echo "  -F <h264 or MJPG>       Select stream format [default:MJPG]"
        echo "  -e <CPU or GPU>         Chooses between vaapi (GPU) or software (CPU) encoding,"
        echo "                          only valid for h264 [default:CPU]"
        echo ""
        exit
        ;;
        esac
done

#udp is used over tcp for latency. udp is allowed to drop packets. if tcp falls behind,
#it tries to catch up and the stream lags behind



# PIPELINE = raw video source -> encode video -> pack into payload -> send to sink



#vaapi = GPU hardware accelerated
#x264 = cpu/software encoding
ENCODER=vaapih264enc
ENCODER='x264enc tune=zerolatency qp-min=18 speed-preset=superfast'



# for h264 streams
if [ "$FORMAT" = 'h264' ]; then
    gst-launch-1.0 -v -e $SOURCE=$VIDEO !
        $EXTRA video/x-raw $CAPS ! \
        queue ! $ENCODER ! rtph264pay ! \
        udpsink host=$IP port=$PORT


## MJPG stream
elif [ "$FORMAT" = 'MJPG' ]; then
    gst-launch-1.0 -v -e $SOURCE=$VIDEO ! \
        $EXTRA image/jpeg $CAPS ! \
        queue ! rtpjpegpay ! \
        udpsink host=$IP port=$PORT
        
else
    echo "Wrong stream format"
fi

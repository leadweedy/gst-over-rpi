#!/bin/bash


./run-gst.sh -f -p 8000 -v "/home/pc/Videos/test1.mp4" &
./run-gst.sh -f -p 8001 -v "/home/pc/Videos/test2.mp4" &
./run-gst.sh -f -p 8002 -v "/home/pc/Videos/test3.mp4"

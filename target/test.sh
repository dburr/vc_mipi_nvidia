#!/bin/bash

export DISPLAY=:0

MODE=$1
CAM=$2

usage() {
  echo "usage: TEST [ v4l | gst ] cam(optional)"
  echo "(specify 'both' for dual-camera demo, only valid for gstreamer mode)"
}

if [ "$MODE" != "v4l" -a "$MODE" != "gst" ]; then
  usage
  exit 1
fi

if [ -z "$CAM" ]; then
  C=0
elif [ $CAM = "both" ]; then
  C="both"
  CAMCMD="both cameras"
elif [[ $CAM =~ ^[+-]?[0-9]+$ ]]; then
  C=$CAM
  if [ $C -lt 0 -o $C -gt 3 ]; then
    echo "invalid camera: $C"
    usage
    exit 1
  fi
else
  usage
  exit 1
fi

if [ "$MODE" = "v4l" ]; then
  if [ "$C" = "both" ]; then
    echo "error: 'both' is invalid for v4l mode"
  exit 1
  fi
  CAMCMD="/dev/video$C"
elif [ "$MODE" = "gst" ]; then
  if [ "$C" != "both" ]; then
    CAMCMD="sensor-id=$C"
  fi
else
  usage
  exit 1
fi

echo "testing $MODE on $CAMCMD"

if [ "$MODE" = "v4l" ]; then
  set -x
  v4l2-ctl -d $CAMCMD \
    --set-fmt-video=width=4056,height=3040,pixelformat=RG10 \
    --set-ctrl exposure=33300,gain=110,bypass_mode=0 \
    --stream-mmap --stream-count=100 --stream-to=capture.raw
elif [ "$MODE" = "gst" ]; then
  if [ "$C" = "both" ]; then
    #echo "'both' demo coming soon!"
    #exit 0

    # Adjust sensor-id (Jetson) or /dev/video* (V4L2) for your setup.
    #
    # sync=false helps when the two live sources aren’t perfectly time-aligned.
    #
    # You can move/resize each input with pad props: sink_N::xpos, ::ypos, ::width, ::height, and even ::alpha (fades/overlays).
    #
    # On Jetson, prefer nvcompositor + nveglglessink to keep frames in NVMM (GPU-accelerated) and avoid unnecessary copies.
    #
    # If your sources deliver high resolutions (e.g., 3280×2464), downscale before the compositor (nvvidconv ! video/x-raw(memory:NVMM),width=... ,height=...) to save bandwidth and GPU.

    # Side-by-side (1920×1080 output; each feed 960×1080)
    if true; then
    gst-launch-1.0 -e \
      nvarguscamerasrc sensor-id=0 \
        exposuretimerange="40000000 40000000" \
        gainrange="8 8" \
        ispdigitalgainrange="1 1" ! \
      'video/x-raw(memory:NVMM),width=1920,height=1080,format=NV12,framerate=30/1' ! nvvidconv ! queue ! comp.sink_0 \
      nvarguscamerasrc sensor-id=1 \
        exposuretimerange="40000000 40000000" \
        gainrange="8 8" \
        ispdigitalgainrange="1 1" ! \
      'video/x-raw(memory:NVMM),width=1920,height=1080,format=NV12,framerate=30/1' ! nvvidconv ! queue ! comp.sink_1 \
      nvcompositor name=comp \
        sink_0::xpos=0   sink_0::ypos=0   sink_0::width=960 sink_0::height=1080 \
        sink_1::xpos=960 sink_1::ypos=0   sink_1::width=960 sink_1::height=1080 \
      ! 'video/x-raw(memory:NVMM),width=1920,height=1080' ! nvvidconv ! xvimagesink
      #nveglglessink sync=false
    else
    # Picture-in-Picture (cam1 full screen, cam2 small at bottom-right)
    gst-launch-1.0 -e \
      nvarguscamerasrc sensor-id=0 ! 'video/x-raw(memory:NVMM),width=1920,height=1080,format=NV12,framerate=30/1' ! nvvidconv ! queue ! comp.sink_0 \
      nvarguscamerasrc sensor-id=1 ! 'video/x-raw(memory:NVMM),width=1280,height=720,format=NV12,framerate=30/1'  ! nvvidconv ! queue ! comp.sink_1 \
      nvcompositor name=comp \
        sink_0::xpos=0   sink_0::ypos=0   sink_0::width=1920 sink_0::height=1080 \
        sink_1::xpos=1280 sink_1::ypos=720 sink_1::width=640  sink_1::height=360 \
      ! 'video/x-raw(memory:NVMM),width=1920,height=1080' ! nvvidconv ! xvimagesink
      #nveglglessink sync=false
    fi
  else
    set -x
    gst-launch-1.0 nvarguscamerasrc \
      $CAMCMD \
      exposuretimerange="40000000 40000000" \
      gainrange="8 8" \
      ispdigitalgainrange="1 1" ! \
      'video/x-raw(memory:NVMM), width=1920, height=1080, format=NV12, framerate=(fraction)21/1' ! \
      nvvidconv ! xvimagesink
  fi
fi

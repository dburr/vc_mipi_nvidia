# Antmicro specific notes

## Building

Make the following selections when running `quickstart.sh`:

* SOM: 9 (NVIDIA Jetson Orin NX 8GB (devkit))
* carrier: 3 (Antmicro Jetson Orin Baseboard v1.1)
  * this entry was created based heavily on 2 (Auvidea JNX42 LM)
* BSP: 1 (NVIDIA L4T 35.2.1)
  * NOTE: Any of the versions listed should work, however 35.2.1 is the only version I have tested so far.

## Testing

[How to test cameras](https://developer.nvidia.com/embedded/learn/tutorials/first-picture-csi-usb-camera)

If the file(s) `/dev/video*` exist then the camera is probably working.

Use `nvgstcapture-1.0` to verify that it is working.

To simultaneously display on screen: `gst-launch-1.0 nvarguscamerasrc ! ' video/x-raw(memory:NVMM),width=3820, height=2464, framerate=21/1, format=NV12' ! nvvidconv flip-method=0 ! ' video/x-raw,width=960, height=616' ! nvvidconv ! nvegltransform ! nveglglessink -e`

While capturing, press:

* `j` to save a frame to disk
* `1` to start recording video to disk
* `0` to stop recording video
* `q` to exit

Automatic capture of stills: `nvgstcapture-1.0 --automate --capture-auto`

Automatic capture of video: `nvgstcapture-1.0 --mode=2 --automate --capture-aut`

## Additional Notes

Setting the following environment variables while running `quickstart.sh`
(or any of the other scripts) will alter their behavior as follows:

* setting `SKIP_RECOVERY_MODE_CHECK="YES"` will skip the check for a board in recovery mode, allowing the scripts to be run even without the presence of such a board
* setting `DEBUG="YES"` will print copious debugging information

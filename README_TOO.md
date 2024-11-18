# Antmicro specific notes

Make the following selections when running `quickstart.sh`:

* SOM: 14 (NVIDIA Jetson Orin Nano 8GB NVME)
* carrier: 3 (Antmicro Jetson Orin Baseboard v1.1)
  * this entry was created based heavily on 2 (Auvidea JNX42 LM)
* BSP: 1 ()
  * NOTE: so far the only one I've tried. Others probably won't work without modification.

# Additional Notes

Setting the following environment variables while running `quickstart.sh`
(or any of the other scripts) will alter their behavior as follows:

* setting `SKIP_RECOVERY_MODE_CHECK="YES"` will skip the check for a board in recovery mode, allowing the scripts to be run even without the presence of such a board
* setting `DEBUG="YES"` will print copious debugging information


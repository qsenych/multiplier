To start genus:
> source /CMC/scripts/cadence.genus19.14.000.csh
> genus 


  * Change the TOP_LEVEL and RUN_NAMES in the runSynth.tcl
  * Change the values on the constraints.tcl based on the project description. Most likely you will need to use v4.

  * The area, timing report will be stored in /reports
  * The gate netlist(.sv), delay file (.sdf) and post synthesis constraint file (.sdc) will be stored in /outputs
  * The checkpoints during synthesis are stored in /chkpts
  * After synthesis, good to simulate the synthesized netlist to ensure correctness before going to PNR.



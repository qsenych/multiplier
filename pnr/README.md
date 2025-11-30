To start innovus

> source /CMC/scripts/cadence.innovus21.17.000.csh
> innovus

  * Every innovus startup will generate a .log, .cmd, .logv file.

The runPNR.tcl script will have  and is divided into 7 parts:
  * Design import -> change the TOP_LEVEL, RUN_NAME, init_top_cell, path to synthesized .sv file, and path to post-synthesis .sdc file in MMMC.tcl.
  * Floorplanning, power network and pins -> The utilization, metal widths/layer and location of pins (add more editPin commands as reqd.) need to be changed.
  
  * Placement -> No change required here. However, ensure that timing is close (<100ps) to meeting and density is below 90%, at the end of this stage.
  * Clock tree synthesis -> Create the cts .sdc file by removing any clock network latency and uncertainity commands. Change the metal layers for CTS routing.
  * Routing -> No change required here. However, ensure that timing is met (setup and hold) and verify_drc and verify_connectivity are clean. Only checkFiller will shows gaps at this stage.
  
Initialization to routing can be run end-to-end without supervision if utilization is reasonable. The filling and drc fixing after fill will require some manual changes.
  * Fixing drc -> The commands shown in this section will need to be run to create 2x column gaps, add fillers, reroute while fixing drcs. Refer to the recorded video.
  * Outputs -> This section exports the postlayout netlist and sdf files to be simulated in modelsim. Everything should be clean here - drc, connectivity, checkFiller, timing (setup and hold).
  
  
  * Any checkpoints saved during the run will be saved in the /chkpts
  * Timing reports generated during the run will be saved in the /reports
  * Postlayout outputs are stored in /output
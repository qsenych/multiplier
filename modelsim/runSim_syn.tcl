set TOP_LEVEL "mkMACBuff"
set TB_NAME ${TOP_LEVEL}_TB

set SDF_FOLDER "/ubc/ece/home/ugrads/q/qsenych/402ELEC/p3/syn/outputs"

# Starting the simulator
vsim -default_radix unsigned -voptargs=+acc -sdfnoerror -sdfmax /$TB_NAME/$TOP_LEVEL=$SDF_FOLDER/${TOP_LEVEL}_map_p3.sdf -l $TB_NAME.sim.log work.${TB_NAME} 

# Open the vcd file to write the waveforms to
vcd file ${TOP_LEVEL}.vcd
# Add the signals to be logged for activity factor
vcd add /$TB_NAME/${TOP_LEVEL}/*

# Add the waves to the Wave viewer
add wave -label CLK -position insertpoint sim:/$TB_NAME/$TOP_LEVEL/CLK

# FILL THIS WITH WAVES TO VIEW
add wave -divider interface_writeMem
add wave -label EN_writeMem -position insertpoint sim:/$TB_NAME/$TOP_LEVEL/EN_writeMem
add wave -label writeMem_addr -position insertpoint sim:/$TB_NAME/$TOP_LEVEL/writeMem_addr

add wave -divider interface_blockRead
add wave -label EN_blockRead -position insertpoint sim:/$TB_NAME/$TOP_LEVEL/EN_blockRead
add wave -divider interface_readMem
add wave -label EN_readMem -position insertpoint sim:/$TB_NAME/$TOP_LEVEL/EN_readMem
add wave -label readmem_addr -position insertpoint sim:/$TB_NAME/$TOP_LEVEL/readMem_addr

add wave -divider interface_memVal
add wave -label VALID_memVal -position insertpoint sim:/$TB_NAME/$TOP_LEVEL/VALID_memVal

add wave -divider others
add wave -label rst_n -position insertpoint sim:/$TB_NAME/RST_N
add wave -label writeMem_val -position insertpoint sim:/$TB_NAME/writeMem_val
add wave -label readMem_val -position insertpoint sim:/$TB_NAME/readMem_val
add wave -label memVal_data -position insertpoint sim:/$TB_NAME/memVal_data
add wave -label stored_val -position insertpoint sim:/$TB_NAME/stored_val
add wave -label curr_state -position insertpoint sim:/$TB_NAME/$TOP_LEVEL/curr_state

add wave -divider pipeline_control
add wave -label pipe0_en -position insertpoint sim:/$TB_NAME/$TOP_LEVEL/pipe0_en
add wave -label pipe1_en -position insertpoint sim:/$TB_NAME/$TOP_LEVEL/pipe1_en
add wave -label pipe2_en -position insertpoint sim:/$TB_NAME/$TOP_LEVEL/pipe2_en
add wave -label pipe3_en -position insertpoint sim:/$TB_NAME/$TOP_LEVEL/pipe3_en
add wave -label pipe4_en -position insertpoint sim:/$TB_NAME/$TOP_LEVEL/pipe4_en
add wave -label pipe5_en -position insertpoint sim:/$TB_NAME/$TOP_LEVEL/pipe5_en

add wave -divider inputs
add wave -label mac_vectA_0 -position insertpoint sim:/$TB_NAME/mac_vectA_0
add wave -label mac_vectB_0 -position insertpoint sim:/$TB_NAME/mac_vectB_0

add wave -divider sums
add wave -label p1sum0m0 -position insertpoint sim:/$TB_NAME/$TOP_LEVEL/p1sum0m0
add wave -label p2sum0m0 -position insertpoint sim:/$TB_NAME/$TOP_LEVEL/p2sum0m0
add wave -label p3outm0 -position insertpoint sim:/$TB_NAME/$TOP_LEVEL/p3outm0
add wave -label p4val_m0m1 -position insertpoint sim:/$TB_NAME/$TOP_LEVEL/p4val_m0m1
add wave -label p5out -position insertpoint sim:/$TB_NAME/$TOP_LEVEL/p5out
run -all

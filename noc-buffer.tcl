# ----------------------------------------
#  Copyright (c) 2018 Cadence Design Systems, Inc. All Rights
#  Reserved.  Unpublished -- rights reserved under the copyright 
#  laws of the United States.
# ----------------------------------------

# Initialize FSV app
check_fsv -init

# FSV utilities
source fsv_utils.tcl

# Read in HDL files
set RTL_PATH hermes_router/rtl/src

#set TOP_MODULE RouterCC
set TOP_MODULE Hermes_buffer

analyze -vhdl ${RTL_PATH}/HeMPS_defaults.vhd \
              ${RTL_PATH}/Hermes_buffer.vhd

#analyze -vhdl ${RTL_PATH}/HeMPS_defaults.vhd \
#            ${RTL_PATH}/Hermes_buffer.vhd \
#            ${RTL_PATH}/Hermes_crossbar.vhd \
#            ${RTL_PATH}/Hermes_switchcontrol.vhd \
#            ${RTL_PATH}/RouterCC.vhd	

# Elaborate and synthesize design
elaborate

# Initialize design
#clock clock -factor 1 -phase 1
clock -infer
reset -expression {reset}

# FSV specific settings
set_fsv_clock_cycle_time 200ns
set_fsv_engine_mode {Bm Ht Hp Tri}
   
set_fsv_structural_propagation_analysis fo
set_fsv_structural_constant_propagation_analysis fo
set_fsv_regs_mapping_optimization on
set_fsv_strobe_optimization on

# Specify custom fault target list (all flops with SEU fault, all signals with other faults)
check_fsv -fault -add [get_design_info -instance ${TOP_MODULE} -list signal -silent] -type SA0+SA1

# Specify the custom strobe list (all checker signals except for can_counter)
check_fsv -fault -add [get_design_info -instance ${TOP_MODULE} -list flop -silent] -type SEU
check_fsv -fault -add [get_design_info -instance ${TOP_MODULE} -list flop -silent] -type SET

# Remove faults in the primary inputs/ouputs. name is case sensitive
check_fsv -fault -remove -node clock
check_fsv -fault -remove -node reset

check_fsv -fault -remove -node clock_rx
check_fsv -fault -remove -node rx
check_fsv -fault -remove -node data_in
check_fsv -fault -remove -node credit_o

#check_fsv -fault -remove -node clock_tx
#check_fsv -fault -remove -node tx
#check_fsv -fault -remove -node data_out
#check_fsv -fault -remove -node credit_i

check_fsv -fault -remove -node h
check_fsv -fault -remove -node ack_h
check_fsv -fault -remove -node data_av
check_fsv -fault -remove -node data
check_fsv -fault -remove -node data_ack
check_fsv -fault -remove -node sender


# Specify SEU for all flops
#check_fsv -strobe -add {credit_o clock_tx tx data_out} -functional
check_fsv -strobe -add {credit_o h data_av data sender} -functional

# structural FSV analysis
check_fsv -structural

# generate FSV properties
check_fsv -generate

# prove FSV properties
check_fsv -prove

# Report FSV results
check_fsv -report -class dangerous
check_fsv -report -force -text ~/fsv.rpt

# FSV Summary
fsv_summary

# prove strategy
#fsv_prove_strategy

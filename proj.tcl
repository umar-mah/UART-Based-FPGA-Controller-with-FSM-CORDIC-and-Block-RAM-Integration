# Make sure to have this file in the main directory outside src and doc directory. If not, it can cause problems in generating a bitstream.

# Set variables
set topmodule top_controller
set outputDir ./build
set rtlDir ./src/rtl
set ipDir ./src/ip
set constraintFile ./src/constraints/Nexys-4-DDR-Master.xdc  ;# Fixed relative path

# Create output directory if not exists
file mkdir $outputDir

# Read design sources
read_verilog $rtlDir/top.sv
read_verilog $rtlDir/controller_fsm.sv
read_verilog $rtlDir/uart.v

# Read IPs (CORDIC and BRAM)
read_ip $ipDir/cordic_0.xci
read_ip $ipDir/blk_mem_gen_0.xci

# Read constraints
read_xdc $constraintFile

# Synthesize design
synth_design -top $topmodule -part xc7a100tcsg324-1
report_timing_summary -file $outputDir/timing_summary_synth.rpt
report_utilization -file $outputDir/utilization_synth.rpt

# Implementation
opt_design
place_design
route_design
report_timing_summary -file $outputDir/timing_summary_impl.rpt
report_utilization -file $outputDir/utilization_impl.rpt

# Generate bitstream
write_bitstream -force $outputDir/$topmodule.bit

# Exit Vivado
exit

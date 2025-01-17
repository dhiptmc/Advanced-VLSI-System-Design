#   Read in top module
read_file -format sverilog {../src/top.sv}

# SET POWER INTENT and ENVIRONMENT ###################################
current_design top
link

#   Set Design Environment
set_host_options -max_core 16
source ../script/DC.sdc
check_design
uniquify
set_fix_multiple_port_nets -all -buffer_constants [get_designs *]
set_max_area 0

# High fanout threshold
set high_fanout_net_threshold 0
report_net_fanout -high_fanout
 
set_structure -timing true

#   Synthesize circuit
compile -map_effort high -area_effort high


remove_unconnected_ports -blast_buses [get_cells -hierarchical *]


report_area > area.log
report_timing > timing.log
report_power > power.log
report_qor > top_syn.qor

#   Create Report
#timing report(setup time)
report_timing -path full -delay max -nworst 1 -max_paths 1 -significant_digits 4 -sort_by group > ../syn/timing_max_rpt.txt
#timing report(hold time)
report_timing -path full -delay min -nworst 1 -max_paths 1 -significant_digits 4 -sort_by group > ../syn/timing_min_rpt.txt
#area report
report_area -nosplit > ../syn/area_rpt.txt
#report power
report_power -analysis_effort low > ../syn/power_rpt.txt

#   Save syntheized file
write -hierarchy -format verilog -output {../syn/top_syn.v}
write_sdf -version 3.0 -context verilog {../syn/top_syn.sdf}
write -format ddc  -hierarchy -output {../syn/top_syn.ddc}
write_sdc -version 2.0 {../syn/top_syn.sdc}

# exit
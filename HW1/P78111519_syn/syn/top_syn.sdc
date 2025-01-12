###################################################################

# Created by write_sdc on Thu Dec 19 14:26:23 2024

###################################################################
set sdc_version 2.0

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_operating_conditions -max WCCOM -max_library                               \
fsa0m_a_generic_core_ss1p62v125c\
                         -min BCCOM -min_library                               \
fsa0m_a_generic_core_ff1p98vm40c
set_max_area 0
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports clk]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports rst]
set_max_capacitance 0.1 [get_ports clk]
set_max_capacitance 0.1 [get_ports rst]
set_max_fanout 10 [get_ports clk]
set_max_fanout 10 [get_ports rst]
set_max_transition 0.1 [get_ports clk]
set_max_transition 0.1 [get_ports rst]
set_ideal_network [get_ports clk]
create_clock [get_ports clk]  -period 13.3  -waveform {0 6.65}
set_clock_latency 0.2  [get_clocks clk]
set_clock_latency -source 0  [get_clocks clk]
set_clock_uncertainty 0.02  [get_clocks clk]
set_clock_transition -max -rise 0.1 [get_clocks clk]
set_clock_transition -max -fall 0.1 [get_clocks clk]
set_clock_transition -min -rise 0.1 [get_clocks clk]
set_clock_transition -min -fall 0.1 [get_clocks clk]
set_input_delay -clock clk  -max 7.98  [get_ports rst]
set_input_delay -clock clk  -min 0  [get_ports rst]

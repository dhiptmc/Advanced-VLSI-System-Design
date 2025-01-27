###################################################################

# Created by write_sdc on Sat Jan 18 05:33:52 2025

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
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports clk2]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports rst2]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[31]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[30]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[29]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[28]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[27]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[26]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[25]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[24]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[23]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[22]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[21]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[20]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[19]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[18]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[17]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[16]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[15]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[14]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[13]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[12]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[11]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[10]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[9]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[8]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[7]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[6]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[5]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[4]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[3]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[2]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[1]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {ROM_out[0]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[31]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[30]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[29]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[28]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[27]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[26]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[25]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[24]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[23]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[22]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[21]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[20]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[19]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[18]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[17]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[16]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[15]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[14]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[13]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[12]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[11]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[10]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[9]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[8]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[7]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[6]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[5]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[4]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[3]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[2]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[1]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports {DRAM_Q[0]}]
set_driving_cell -lib_cell XMD -library fsa0m_a_t33_generic_io_ss1p62v125c     \
-pin O [get_ports DRAM_valid]
set_load -pin_load 0.05 [get_ports ROM_read]
set_load -pin_load 0.05 [get_ports ROM_enable]
set_load -pin_load 0.05 [get_ports {ROM_address[11]}]
set_load -pin_load 0.05 [get_ports {ROM_address[10]}]
set_load -pin_load 0.05 [get_ports {ROM_address[9]}]
set_load -pin_load 0.05 [get_ports {ROM_address[8]}]
set_load -pin_load 0.05 [get_ports {ROM_address[7]}]
set_load -pin_load 0.05 [get_ports {ROM_address[6]}]
set_load -pin_load 0.05 [get_ports {ROM_address[5]}]
set_load -pin_load 0.05 [get_ports {ROM_address[4]}]
set_load -pin_load 0.05 [get_ports {ROM_address[3]}]
set_load -pin_load 0.05 [get_ports {ROM_address[2]}]
set_load -pin_load 0.05 [get_ports {ROM_address[1]}]
set_load -pin_load 0.05 [get_ports {ROM_address[0]}]
set_load -pin_load 0.05 [get_ports DRAM_CSn]
set_load -pin_load 0.05 [get_ports {DRAM_WEn[3]}]
set_load -pin_load 0.05 [get_ports {DRAM_WEn[2]}]
set_load -pin_load 0.05 [get_ports {DRAM_WEn[1]}]
set_load -pin_load 0.05 [get_ports {DRAM_WEn[0]}]
set_load -pin_load 0.05 [get_ports DRAM_RASn]
set_load -pin_load 0.05 [get_ports DRAM_CASn]
set_load -pin_load 0.05 [get_ports {DRAM_A[10]}]
set_load -pin_load 0.05 [get_ports {DRAM_A[9]}]
set_load -pin_load 0.05 [get_ports {DRAM_A[8]}]
set_load -pin_load 0.05 [get_ports {DRAM_A[7]}]
set_load -pin_load 0.05 [get_ports {DRAM_A[6]}]
set_load -pin_load 0.05 [get_ports {DRAM_A[5]}]
set_load -pin_load 0.05 [get_ports {DRAM_A[4]}]
set_load -pin_load 0.05 [get_ports {DRAM_A[3]}]
set_load -pin_load 0.05 [get_ports {DRAM_A[2]}]
set_load -pin_load 0.05 [get_ports {DRAM_A[1]}]
set_load -pin_load 0.05 [get_ports {DRAM_A[0]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[31]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[30]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[29]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[28]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[27]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[26]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[25]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[24]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[23]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[22]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[21]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[20]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[19]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[18]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[17]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[16]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[15]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[14]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[13]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[12]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[11]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[10]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[9]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[8]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[7]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[6]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[5]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[4]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[3]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[2]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[1]}]
set_load -pin_load 0.05 [get_ports {DRAM_D[0]}]
set_max_fanout 6 [get_ports clk]
set_max_fanout 6 [get_ports rst]
set_max_fanout 6 [get_ports clk2]
set_max_fanout 6 [get_ports rst2]
set_max_fanout 6 [get_ports {ROM_out[31]}]
set_max_fanout 6 [get_ports {ROM_out[30]}]
set_max_fanout 6 [get_ports {ROM_out[29]}]
set_max_fanout 6 [get_ports {ROM_out[28]}]
set_max_fanout 6 [get_ports {ROM_out[27]}]
set_max_fanout 6 [get_ports {ROM_out[26]}]
set_max_fanout 6 [get_ports {ROM_out[25]}]
set_max_fanout 6 [get_ports {ROM_out[24]}]
set_max_fanout 6 [get_ports {ROM_out[23]}]
set_max_fanout 6 [get_ports {ROM_out[22]}]
set_max_fanout 6 [get_ports {ROM_out[21]}]
set_max_fanout 6 [get_ports {ROM_out[20]}]
set_max_fanout 6 [get_ports {ROM_out[19]}]
set_max_fanout 6 [get_ports {ROM_out[18]}]
set_max_fanout 6 [get_ports {ROM_out[17]}]
set_max_fanout 6 [get_ports {ROM_out[16]}]
set_max_fanout 6 [get_ports {ROM_out[15]}]
set_max_fanout 6 [get_ports {ROM_out[14]}]
set_max_fanout 6 [get_ports {ROM_out[13]}]
set_max_fanout 6 [get_ports {ROM_out[12]}]
set_max_fanout 6 [get_ports {ROM_out[11]}]
set_max_fanout 6 [get_ports {ROM_out[10]}]
set_max_fanout 6 [get_ports {ROM_out[9]}]
set_max_fanout 6 [get_ports {ROM_out[8]}]
set_max_fanout 6 [get_ports {ROM_out[7]}]
set_max_fanout 6 [get_ports {ROM_out[6]}]
set_max_fanout 6 [get_ports {ROM_out[5]}]
set_max_fanout 6 [get_ports {ROM_out[4]}]
set_max_fanout 6 [get_ports {ROM_out[3]}]
set_max_fanout 6 [get_ports {ROM_out[2]}]
set_max_fanout 6 [get_ports {ROM_out[1]}]
set_max_fanout 6 [get_ports {ROM_out[0]}]
set_max_fanout 6 [get_ports {DRAM_Q[31]}]
set_max_fanout 6 [get_ports {DRAM_Q[30]}]
set_max_fanout 6 [get_ports {DRAM_Q[29]}]
set_max_fanout 6 [get_ports {DRAM_Q[28]}]
set_max_fanout 6 [get_ports {DRAM_Q[27]}]
set_max_fanout 6 [get_ports {DRAM_Q[26]}]
set_max_fanout 6 [get_ports {DRAM_Q[25]}]
set_max_fanout 6 [get_ports {DRAM_Q[24]}]
set_max_fanout 6 [get_ports {DRAM_Q[23]}]
set_max_fanout 6 [get_ports {DRAM_Q[22]}]
set_max_fanout 6 [get_ports {DRAM_Q[21]}]
set_max_fanout 6 [get_ports {DRAM_Q[20]}]
set_max_fanout 6 [get_ports {DRAM_Q[19]}]
set_max_fanout 6 [get_ports {DRAM_Q[18]}]
set_max_fanout 6 [get_ports {DRAM_Q[17]}]
set_max_fanout 6 [get_ports {DRAM_Q[16]}]
set_max_fanout 6 [get_ports {DRAM_Q[15]}]
set_max_fanout 6 [get_ports {DRAM_Q[14]}]
set_max_fanout 6 [get_ports {DRAM_Q[13]}]
set_max_fanout 6 [get_ports {DRAM_Q[12]}]
set_max_fanout 6 [get_ports {DRAM_Q[11]}]
set_max_fanout 6 [get_ports {DRAM_Q[10]}]
set_max_fanout 6 [get_ports {DRAM_Q[9]}]
set_max_fanout 6 [get_ports {DRAM_Q[8]}]
set_max_fanout 6 [get_ports {DRAM_Q[7]}]
set_max_fanout 6 [get_ports {DRAM_Q[6]}]
set_max_fanout 6 [get_ports {DRAM_Q[5]}]
set_max_fanout 6 [get_ports {DRAM_Q[4]}]
set_max_fanout 6 [get_ports {DRAM_Q[3]}]
set_max_fanout 6 [get_ports {DRAM_Q[2]}]
set_max_fanout 6 [get_ports {DRAM_Q[1]}]
set_max_fanout 6 [get_ports {DRAM_Q[0]}]
set_max_fanout 6 [get_ports DRAM_valid]
set_ideal_network [get_ports clk]
set_ideal_network [get_ports clk2]
create_clock [get_ports clk]  -period 15  -waveform {0 7.5}
set_clock_latency 1  [get_clocks clk]
set_clock_uncertainty 0.1  [get_clocks clk]
create_clock [get_ports clk2]  -period 100  -waveform {0 50}
set_clock_latency 1  [get_clocks clk2]
set_clock_uncertainty 0.1  [get_clocks clk2]
set_input_delay -clock clk  -max 7.5  [get_ports rst]
set_input_delay -clock clk  -min 0  [get_ports rst]
set_input_delay -clock clk  -max 7.5  [get_ports rst2]
set_input_delay -clock clk  -min 0  [get_ports rst2]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[31]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[31]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[30]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[30]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[29]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[29]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[28]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[28]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[27]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[27]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[26]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[26]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[25]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[25]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[24]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[24]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[23]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[23]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[22]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[22]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[21]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[21]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[20]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[20]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[19]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[19]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[18]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[18]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[17]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[17]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[16]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[16]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[15]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[15]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[14]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[14]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[13]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[13]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[12]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[12]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[11]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[11]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[10]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[10]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[9]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[9]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[8]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[8]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[7]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[7]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[6]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[6]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[5]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[5]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[4]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[4]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[3]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[3]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[2]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[2]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[1]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[1]}]
set_input_delay -clock clk  -max 7.5  [get_ports {ROM_out[0]}]
set_input_delay -clock clk  -min 0  [get_ports {ROM_out[0]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[31]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[31]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[30]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[30]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[29]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[29]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[28]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[28]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[27]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[27]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[26]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[26]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[25]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[25]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[24]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[24]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[23]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[23]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[22]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[22]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[21]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[21]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[20]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[20]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[19]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[19]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[18]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[18]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[17]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[17]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[16]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[16]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[15]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[15]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[14]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[14]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[13]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[13]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[12]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[12]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[11]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[11]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[10]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[10]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[9]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[9]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[8]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[8]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[7]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[7]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[6]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[6]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[5]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[5]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[4]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[4]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[3]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[3]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[2]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[2]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[1]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[1]}]
set_input_delay -clock clk  -max 7.5  [get_ports {DRAM_Q[0]}]
set_input_delay -clock clk  -min 0  [get_ports {DRAM_Q[0]}]
set_input_delay -clock clk  -max 7.5  [get_ports DRAM_valid]
set_input_delay -clock clk  -min 0  [get_ports DRAM_valid]
set_output_delay -clock clk  -max 7.5  [get_ports ROM_read]
set_output_delay -clock clk  -min 0  [get_ports ROM_read]
set_output_delay -clock clk  -max 7.5  [get_ports ROM_enable]
set_output_delay -clock clk  -min 0  [get_ports ROM_enable]
set_output_delay -clock clk  -max 7.5  [get_ports {ROM_address[11]}]
set_output_delay -clock clk  -min 0  [get_ports {ROM_address[11]}]
set_output_delay -clock clk  -max 7.5  [get_ports {ROM_address[10]}]
set_output_delay -clock clk  -min 0  [get_ports {ROM_address[10]}]
set_output_delay -clock clk  -max 7.5  [get_ports {ROM_address[9]}]
set_output_delay -clock clk  -min 0  [get_ports {ROM_address[9]}]
set_output_delay -clock clk  -max 7.5  [get_ports {ROM_address[8]}]
set_output_delay -clock clk  -min 0  [get_ports {ROM_address[8]}]
set_output_delay -clock clk  -max 7.5  [get_ports {ROM_address[7]}]
set_output_delay -clock clk  -min 0  [get_ports {ROM_address[7]}]
set_output_delay -clock clk  -max 7.5  [get_ports {ROM_address[6]}]
set_output_delay -clock clk  -min 0  [get_ports {ROM_address[6]}]
set_output_delay -clock clk  -max 7.5  [get_ports {ROM_address[5]}]
set_output_delay -clock clk  -min 0  [get_ports {ROM_address[5]}]
set_output_delay -clock clk  -max 7.5  [get_ports {ROM_address[4]}]
set_output_delay -clock clk  -min 0  [get_ports {ROM_address[4]}]
set_output_delay -clock clk  -max 7.5  [get_ports {ROM_address[3]}]
set_output_delay -clock clk  -min 0  [get_ports {ROM_address[3]}]
set_output_delay -clock clk  -max 7.5  [get_ports {ROM_address[2]}]
set_output_delay -clock clk  -min 0  [get_ports {ROM_address[2]}]
set_output_delay -clock clk  -max 7.5  [get_ports {ROM_address[1]}]
set_output_delay -clock clk  -min 0  [get_ports {ROM_address[1]}]
set_output_delay -clock clk  -max 7.5  [get_ports {ROM_address[0]}]
set_output_delay -clock clk  -min 0  [get_ports {ROM_address[0]}]
set_output_delay -clock clk  -max 7.5  [get_ports DRAM_CSn]
set_output_delay -clock clk  -min 0  [get_ports DRAM_CSn]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_WEn[3]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_WEn[3]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_WEn[2]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_WEn[2]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_WEn[1]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_WEn[1]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_WEn[0]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_WEn[0]}]
set_output_delay -clock clk  -max 7.5  [get_ports DRAM_RASn]
set_output_delay -clock clk  -min 0  [get_ports DRAM_RASn]
set_output_delay -clock clk  -max 7.5  [get_ports DRAM_CASn]
set_output_delay -clock clk  -min 0  [get_ports DRAM_CASn]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_A[10]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_A[10]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_A[9]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_A[9]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_A[8]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_A[8]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_A[7]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_A[7]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_A[6]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_A[6]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_A[5]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_A[5]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_A[4]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_A[4]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_A[3]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_A[3]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_A[2]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_A[2]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_A[1]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_A[1]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_A[0]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_A[0]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[31]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[31]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[30]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[30]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[29]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[29]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[28]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[28]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[27]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[27]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[26]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[26]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[25]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[25]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[24]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[24]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[23]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[23]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[22]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[22]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[21]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[21]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[20]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[20]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[19]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[19]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[18]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[18]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[17]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[17]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[16]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[16]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[15]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[15]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[14]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[14]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[13]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[13]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[12]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[12]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[11]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[11]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[10]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[10]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[9]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[9]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[8]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[8]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[7]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[7]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[6]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[6]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[5]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[5]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[4]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[4]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[3]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[3]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[2]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[2]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[1]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[1]}]
set_output_delay -clock clk  -max 7.5  [get_ports {DRAM_D[0]}]
set_output_delay -clock clk  -min 0  [get_ports {DRAM_D[0]}]
set_clock_groups  -asynchronous -name clk_1  -group [get_clocks clk] -group    \
[get_clocks clk2]

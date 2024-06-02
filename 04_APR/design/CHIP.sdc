###################################################################

# Created by write_sdc on Thu May 30 16:15:47 2024

###################################################################
set sdc_version 2.1

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_operating_conditions -max WCCOM -max_library                               \
fsa0m_a_generic_core_ss1p62v125c\
                         -min BCCOM -min_library                               \
fsa0m_a_generic_core_ff1p98vm40c
set_wire_load_model -name G200K -library fsa0m_a_generic_core_tt1p8v25c
set_max_area 0
set_load -pin_load 10 [get_ports {o_data[7]}]
set_load -pin_load 10 [get_ports {o_data[6]}]
set_load -pin_load 10 [get_ports {o_data[5]}]
set_load -pin_load 10 [get_ports {o_data[4]}]
set_load -pin_load 10 [get_ports {o_data[3]}]
set_load -pin_load 10 [get_ports {o_data[2]}]
set_load -pin_load 10 [get_ports {o_data[1]}]
set_load -pin_load 10 [get_ports {o_data[0]}]
set_load -pin_load 10 [get_ports o_valid]
create_clock [get_ports i_clk]  -period 20  -waveform {0 10}
set_clock_latency 0.5  [get_clocks i_clk]
set_clock_uncertainty 0.1  [get_clocks i_clk]
set_input_delay -clock i_clk  -max 1  [get_ports i_clk]
set_input_delay -clock i_clk  -max 1  [get_ports i_rst]
set_input_delay -clock i_clk  -max 1  [get_ports {i_data[15]}]
set_input_delay -clock i_clk  -max 1  [get_ports {i_data[14]}]
set_input_delay -clock i_clk  -max 1  [get_ports {i_data[13]}]
set_input_delay -clock i_clk  -max 1  [get_ports {i_data[12]}]
set_input_delay -clock i_clk  -max 1  [get_ports {i_data[11]}]
set_input_delay -clock i_clk  -max 1  [get_ports {i_data[10]}]
set_input_delay -clock i_clk  -max 1  [get_ports {i_data[9]}]
set_input_delay -clock i_clk  -max 1  [get_ports {i_data[8]}]
set_input_delay -clock i_clk  -max 1  [get_ports {i_data[7]}]
set_input_delay -clock i_clk  -max 1  [get_ports {i_data[6]}]
set_input_delay -clock i_clk  -max 1  [get_ports {i_data[5]}]
set_input_delay -clock i_clk  -max 1  [get_ports {i_data[4]}]
set_input_delay -clock i_clk  -max 1  [get_ports {i_data[3]}]
set_input_delay -clock i_clk  -max 1  [get_ports {i_data[2]}]
set_input_delay -clock i_clk  -max 1  [get_ports {i_data[1]}]
set_input_delay -clock i_clk  -max 1  [get_ports {i_data[0]}]
set_input_delay -clock i_clk  -max 1  [get_ports i_valid]
set_output_delay -clock i_clk  -min 0.5  [get_ports {o_data[7]}]
set_output_delay -clock i_clk  -min 0.5  [get_ports {o_data[6]}]
set_output_delay -clock i_clk  -min 0.5  [get_ports {o_data[5]}]
set_output_delay -clock i_clk  -min 0.5  [get_ports {o_data[4]}]
set_output_delay -clock i_clk  -min 0.5  [get_ports {o_data[3]}]
set_output_delay -clock i_clk  -min 0.5  [get_ports {o_data[2]}]
set_output_delay -clock i_clk  -min 0.5  [get_ports {o_data[1]}]
set_output_delay -clock i_clk  -min 0.5  [get_ports {o_data[0]}]
set_output_delay -clock i_clk  -min 0.5  [get_ports o_valid]
set_drive 1  [get_ports i_clk]
set_drive 1  [get_ports i_rst]
set_drive 1  [get_ports {i_data[15]}]
set_drive 1  [get_ports {i_data[14]}]
set_drive 1  [get_ports {i_data[13]}]
set_drive 1  [get_ports {i_data[12]}]
set_drive 1  [get_ports {i_data[11]}]
set_drive 1  [get_ports {i_data[10]}]
set_drive 1  [get_ports {i_data[9]}]
set_drive 1  [get_ports {i_data[8]}]
set_drive 1  [get_ports {i_data[7]}]
set_drive 1  [get_ports {i_data[6]}]
set_drive 1  [get_ports {i_data[5]}]
set_drive 1  [get_ports {i_data[4]}]
set_drive 1  [get_ports {i_data[3]}]
set_drive 1  [get_ports {i_data[2]}]
set_drive 1  [get_ports {i_data[1]}]
set_drive 1  [get_ports {i_data[0]}]
set_drive 1  [get_ports i_valid]

create_clock -name clk -period 10.000 [get_ports clk]

set_input_delay 1.0 -clock clk [get_ports {rst valid a[*] b[*]}]

set_output_delay 1.0 -clock clk [get_ports {acc[*]}]

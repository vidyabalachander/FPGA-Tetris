# Create work library
vlib work

# Compile Verilog
#     All Verilog files that are part of this design should have
#     their own "vlog" line below.
vlog "./LEDDriver.sv"
vlog "./clock_divider.sv"
vlog "./lfsr.sv"
vlog "./piece.sv"
vlog "./home_screen.sv"
vlog "./series_ff.sv"
vlog "./userInput.sv"
vlog "./board_state.sv"
vlog "./display.sv"
vlog "./over_screen.sv"
vlog "./game_fsm.sv"
vlog "./score_display.sv"
vlog "./DE1_SoC.sv"

# Call vsim to invoke simulator
#     Make sure the last item on the line is the name of the
#     testbench module you want to execute.
vsim -voptargs="+acc" -t 1ps -lib work DE1_SoC_testbench

# Source the wave do file
#     This should be the file that sets up the signal window for
#     the module you are testing.
do DE1_SoC_wave.do

# Set the window types
view wave
view structure
view signals

# Run the simulation
run -all

# End

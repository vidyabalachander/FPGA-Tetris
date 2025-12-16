module lfsr(clk, reset, lfsr_o);
	input logic clk, reset;
	output logic [2:0] lfsr_o;
	
	always_ff @(posedge clk or posedge reset) begin
		if (reset) 
			lfsr_o <= 3'b001;
		else
			lfsr_o <= {lfsr_o[1:0], lfsr_o[2] ~^ lfsr_o[1]};
	end
endmodule

module lfsr_testbench();
    logic clk, reset;
    logic [2:0] lfsr_o;

    lfsr dut (
        .clk(clk),
        .reset(reset),
        .lfsr_o(lfsr_o)
    );

    // Clock generation
    parameter CLOCK_PERIOD = 10;
    initial begin
        clk = 0;
        forever #(CLOCK_PERIOD/2) clk = ~clk;
    end

    // Reset sequence
    initial begin
        reset = 1;
        #(CLOCK_PERIOD * 2);
        reset = 0;
    end

    // Run simulation for a while then stop
    initial begin
        #(CLOCK_PERIOD * 200);
        $stop;
    end
	 
endmodule

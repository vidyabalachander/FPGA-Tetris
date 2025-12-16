module score_display (
	input logic [5:0] lines,
	output logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);

	always_comb begin
		if (lines[0])
			HEX0 = 7'b1111001;
		else
			HEX0 = 7'b1000000;
		if (lines[1])
			HEX1 = 7'b1111001;
		else
			HEX1 = 7'b1000000;
		if (lines[2])
			HEX2 = 7'b1111001;
		else
			HEX2 = 7'b1000000;
		if (lines[3])
			HEX3 = 7'b1111001;
		else
			HEX3 = 7'b1000000;
		if (lines[4])
			HEX4 = 7'b1111001;
		else
			HEX4 = 7'b1000000;
		if (lines[5])
			HEX5 = 7'b1111001;
		else
			HEX5 = 7'b1000000;
	end
endmodule

module score_display_testbench();
    logic [5:0] lines;
    logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
    
    score_display dut (
        .lines(lines),
        .HEX0(HEX0),
        .HEX1(HEX1),
        .HEX2(HEX2),
        .HEX3(HEX3),
        .HEX4(HEX4),
        .HEX5(HEX5)
    );
    
    initial begin
        // Test all possible values from 0 to 63
        for (int i = 0; i < 64; i++) begin
            lines = i[5:0];
            #10;
        end
        
        $stop;
    end
    
endmodule

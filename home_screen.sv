module home_screen (RedPixels, GrnPixels);
    output logic [15:0][15:0] RedPixels; // 16x16 array of red LEDs
    output logic [15:0][15:0] GrnPixels; // 16x16 array of green LEDs
	 
	 always_comb 
	 begin
	  //                  FEDCBA9876543210
	  RedPixels[00] = 16'b0000000000000000;
	  RedPixels[01] = 16'b0000000000000000;
	  RedPixels[02] = 16'b0011100000111000;
	  RedPixels[03] = 16'b0001000000010000;
	  RedPixels[04] = 16'b0001000000010000;
	  RedPixels[05] = 16'b0001000000010000;
	  RedPixels[06] = 16'b0001000000010000;
	  RedPixels[07] = 16'b0000000000000000;
	  RedPixels[08] = 16'b0000000000000000;
	  RedPixels[09] = 16'b0011101110000000;
	  RedPixels[10] = 16'b0010100100000000;
	  RedPixels[11] = 16'b0011100100000000;
	  RedPixels[12] = 16'b0011000100000000;
	  RedPixels[13] = 16'b0010101110000000;
	  RedPixels[14] = 16'b0000000000000000;
	  RedPixels[15] = 16'b0000000000000000;
	  
	  //                  FEDCBA9876543210
	  GrnPixels[00] = 16'b0000000000000000;
	  GrnPixels[01] = 16'b0000000000000000;
	  GrnPixels[02] = 16'b0000001110111000;
	  GrnPixels[03] = 16'b0000001000010000;
	  GrnPixels[04] = 16'b0000001100010000;
	  GrnPixels[05] = 16'b0000001000010000;
	  GrnPixels[06] = 16'b0000001110010000;
	  GrnPixels[07] = 16'b0000000000000000;
	  GrnPixels[08] = 16'b0000000000000000;
	  GrnPixels[09] = 16'b0011100000111000;
	  GrnPixels[10] = 16'b0010100000100000;
	  GrnPixels[11] = 16'b0011100000111000;
	  GrnPixels[12] = 16'b0011000000001000;
	  GrnPixels[13] = 16'b0010100000111000;
	  GrnPixels[14] = 16'b0000000000000000;
	  GrnPixels[15] = 16'b0000000000000000;
	end

endmodule


module home_screen_testbench();

	logic [15:0][15:0] GrnPixels;
	logic [15:0][15:0] RedPixels;
	
	home_screen dut (.RedPixels, .GrnPixels);
	
	initial begin
	end
	
endmodule
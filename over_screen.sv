module over_screen (RedPixels, GrnPixels);
    output logic [15:0][15:0] RedPixels; // 16x16 array of red LEDs
    output logic [15:0][15:0] GrnPixels; // 16x16 array of green LEDs
	 
	 always_comb 
	 begin
	  //                  FEDCBA9876543210
	  RedPixels[00] = 16'b0000000000000000;
	  RedPixels[01] = 16'b1111000010001000;
	  RedPixels[02] = 16'b1000000011011000;
	  RedPixels[03] = 16'b1011000010101000;
	  RedPixels[04] = 16'b1001000010001000;
	  RedPixels[05] = 16'b1111000010001000;
	  RedPixels[06] = 16'b0000000000000000;
	  RedPixels[07] = 16'b0000000000000000;
	  RedPixels[08] = 16'b0000000000000000;
	  RedPixels[09] = 16'b0000100010001111;
	  RedPixels[10] = 16'b0000100010001001;
	  RedPixels[11] = 16'b0000010100001111;
	  RedPixels[12] = 16'b0000010100001010;
	  RedPixels[13] = 16'b0000001000001001;
	  RedPixels[14] = 16'b0000000000000000;
	  RedPixels[15] = 16'b0000000000000000;
	  
	  //                  FEDCBA9876543210
	  GrnPixels[00] = 16'b0000000000000000;
	  GrnPixels[01] = 16'b0000111110001111;
	  GrnPixels[02] = 16'b0000100111011100;
	  GrnPixels[03] = 16'b0000111110101111;
	  GrnPixels[04] = 16'b0000100110001100;
	  GrnPixels[05] = 16'b0000100110001111;
	  GrnPixels[06] = 16'b0000000000000000;
	  GrnPixels[07] = 16'b0000000000000000;
	  GrnPixels[08] = 16'b0000000000000000;
	  GrnPixels[09] = 16'b1111100011110000;
	  GrnPixels[10] = 16'b1001100011000000;
	  GrnPixels[11] = 16'b1001010101110000;
	  GrnPixels[12] = 16'b1001010101000000;
	  GrnPixels[13] = 16'b1111001001110000;
	  GrnPixels[14] = 16'b0000000000000000;
	  GrnPixels[15] = 16'b0000000000000000;
	end

endmodule


module over_screen_testbench();

	logic [15:0][15:0] GrnPixels;
	logic [15:0][15:0] RedPixels;
	
	over_screen dut (.RedPixels, .GrnPixels);
	
	initial begin
	end
	
endmodule
// Top-level module that defines the I/Os for the DE-1 SoC board
module DE1_SoC (HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, KEY, SW, LEDR, GPIO_1, CLOCK_50);
	output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	output logic [9:0]  LEDR;
	input  logic [3:0]  KEY;
	input  logic [9:0]  SW;
	output logic [35:0] GPIO_1;
	input logic CLOCK_50;

	/* Set up system base clock to 1526 Hz (50 MHz / 2**(14+1))
	 ===========================================================*/
	logic [31:0] clk;
	logic SYSTEM_CLOCK;

	clock_divider divider (.clock(CLOCK_50), .divided_clocks(clk));

	assign SYSTEM_CLOCK = clk[14]; // 1526 Hz clock signal	 

	/* If you notice flickering, set SYSTEM_CLOCK faster.
	 However, this may reduce the brightness of the LED board. */

	/* Set up LED board driver
	 ================================================================== */
	logic [15:0][15:0]RedPixels; // 16 x 16 array representing red LEDs
	logic [15:0][15:0]GrnPixels; // 16 x 16 array representing green LEDs
	logic reset;                   // reset - toggle this on startup
	
	assign reset = SW[9]; // added reset signal

	logic left, right, rotate, drop;
	logic game_over;
	logic [1:0] state;

	logic [3:0] key_sync;

	series_ff sync3  (.clk(SYSTEM_CLOCK), .d(~KEY[3]), .q(key_sync[3]));
	series_ff sync2  (.clk(SYSTEM_CLOCK), .d(~KEY[2]), .q(key_sync[2]));
	series_ff sync1  (.clk(SYSTEM_CLOCK), .d(~KEY[1]), .q(key_sync[1]));
	series_ff sync0  (.clk(SYSTEM_CLOCK), .d(~KEY[0]), .q(key_sync[0]));

	userInput input3 	(.clk(SYSTEM_CLOCK), .reset(reset), .B(key_sync[3]), .P(left));
	userInput input2 	(.clk(SYSTEM_CLOCK), .reset(reset), .B(key_sync[2]), .P(right));
	userInput input1 	(.clk(SYSTEM_CLOCK), .reset(reset), .B(key_sync[1]), .P(rotate));
	userInput input0 	(.clk(SYSTEM_CLOCK), .reset(reset), .B(key_sync[0]), .P(drop));


	/* Standard LED Driver instantiation - set once and 'forget it'. 
	 See LEDDriver.sv for more info. Do not modify unless you know what you are doing! */
	LEDDriver Driver (.clk(SYSTEM_CLOCK), .reset, .EnableCount(1'b1), .RedPixels, .GrnPixels, .GPIO_1);
		
	logic [15:0][15:0] RedPixels_home, GrnPixels_home;
	logic [15:0][15:0] RedPixels_board, GrnPixels_board;
	logic [15:0][15:0] RedPixels_play, GrnPixels_play;
	logic [15:0][15:0] RedPixels_over, GrnPixels_over;
	
	logic [15:0][15:0] occupancy;
	logic [15:0] piece_bitmap, next_piece_bitmap;
	logic [3:0] curr_x, curr_y;
	logic lock;
	logic [5:0] lines;
	
	game_fsm			controller 		(.clk(SYSTEM_CLOCK), .reset, .game_over, .state, 
											.user(left || right || rotate || drop));

	home_screen 	home 				(.RedPixels(RedPixels_home), .GrnPixels(GrnPixels_home));
	
	piece 			curr_piece 		(.clk(SYSTEM_CLOCK), .reset, .left, .right, .rotate, .drop, .occupancy, .state, 
											.piece_bitmap_out(piece_bitmap), .next_piece_bitmap, .curr_x_out(curr_x), 
											.curr_y_out(curr_y), .lock_out(lock));
	
	board_state 	board				(.clk(SYSTEM_CLOCK), .reset, .lock_in(lock), .piece_map_in(piece_bitmap),
											.piece_x_in(curr_x), .piece_y_in(curr_y), .occupancy, .game_over, .lines, 
											.RedPixels(RedPixels_board), .GrnPixels(GrnPixels_board));
											
	display 			play_display 	(.RedPixels_board, .GrnPixels_board, .curr_piece_map(piece_bitmap), 
											.curr_x, .curr_y, .next_piece_map(next_piece_bitmap), .RedPixels(RedPixels_play),
											.GrnPixels(GrnPixels_play));
	
	score_display	score				(.lines, .HEX0, .HEX1, .HEX2, .HEX3, .HEX4, .HEX5);
	
	over_screen		over				(.RedPixels(RedPixels_over), .GrnPixels(GrnPixels_over));

	// MUX logic to select which display is visible based on the game state
	always_comb begin
		// default
		RedPixels = RedPixels_over;
		GrnPixels = GrnPixels_over;

		case (state)
			00: begin
				RedPixels = RedPixels_home;
				GrnPixels = GrnPixels_home;
			end
			01: begin
				RedPixels = RedPixels_play;
				GrnPixels = GrnPixels_play;
			end
			10: begin
				RedPixels = RedPixels_over;
				GrnPixels = GrnPixels_over;
			end
		endcase
	end
	 
endmodule

module DE1_SoC_testbench();
	logic [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5;
	logic [9:0] LEDR;
	logic [3:0] KEY;
	logic [9:0] SW;
	logic [35:0] GPIO_1;
	logic CLOCK_50;
	
	DE1_SoC dut (
		.HEX0(HEX0),
		.HEX1(HEX1),
		.HEX2(HEX2),
		.HEX3(HEX3),
		.HEX4(HEX4),
		.HEX5(HEX5),
		.KEY(KEY),
		.SW(SW),
		.LEDR(LEDR),
		.GPIO_1(GPIO_1),
		.CLOCK_50(CLOCK_50)
	);
		
	parameter CLOCK_PERIOD = 10;
	initial begin
		CLOCK_50 = 0;
		forever #(CLOCK_PERIOD/2) CLOCK_50 = ~CLOCK_50;
	end
	
	initial begin
		force dut.SYSTEM_CLOCK = CLOCK_50;

		KEY = 4'b1111;
		SW = 10'b0;
		
		// reset shows home screen
		SW[9] = 1'b1;
		repeat(50) @(posedge CLOCK_50);
		SW[9] = 1'b0;
		repeat(50) @(posedge CLOCK_50);
		
		// start game
		KEY[0] = 1'b0;
		repeat(5) @(posedge CLOCK_50);
		KEY[0] = 1'b1;
		repeat(50) @(posedge CLOCK_50);
		
		// move left
		KEY[3] = 1'b0;
		repeat(5) @(posedge CLOCK_50);
		KEY[3] = 1'b1;
		repeat(50) @(posedge CLOCK_50);
		
		KEY[3] = 1'b0;
		repeat(5) @(posedge CLOCK_50);
		KEY[3] = 1'b1;
		repeat(50) @(posedge CLOCK_50);
		
		// move right
		KEY[2] = 1'b0;
		repeat(5) @(posedge CLOCK_50);
		KEY[2] = 1'b1;
		repeat(50) @(posedge CLOCK_50);
		
		KEY[2] = 1'b0;
		repeat(5) @(posedge CLOCK_50);
		KEY[2] = 1'b1;
		repeat(50) @(posedge CLOCK_50);
		
		KEY[2] = 1'b0;
		repeat(5) @(posedge CLOCK_50);
		KEY[2] = 1'b1;
		repeat(50) @(posedge CLOCK_50);
		
		// rotate
		KEY[1] = 1'b0;
		repeat(5) @(posedge CLOCK_50);
		KEY[1] = 1'b1;
		repeat(50) @(posedge CLOCK_50);
		
		KEY[1] = 1'b0;
		repeat(5) @(posedge CLOCK_50);
		KEY[1] = 1'b1;
		repeat(50) @(posedge CLOCK_50);
		
		KEY[1] = 1'b0;
		repeat(5) @(posedge CLOCK_50);
		KEY[1] = 1'b1;
		repeat(50) @(posedge CLOCK_50);
		
		KEY[1] = 1'b0;
		repeat(5) @(posedge CLOCK_50);
		KEY[1] = 1'b1;
		repeat(50) @(posedge CLOCK_50);
		
		// dropping
		KEY[0] = 1'b0;
		repeat(5) @(posedge CLOCK_50);
		KEY[0] = 1'b1;
		repeat(50) @(posedge CLOCK_50);
		
		// placing many pieces
		KEY[3] = 1'b0;
		repeat(5) @(posedge CLOCK_50);
		KEY[3] = 1'b1;
		repeat(50) @(posedge CLOCK_50);
		
		KEY[0] = 1'b0;
		repeat(5) @(posedge CLOCK_50);
		KEY[0] = 1'b1;
		repeat(50) @(posedge CLOCK_50);
		
		KEY[2] = 1'b0;
		repeat(5) @(posedge CLOCK_50);
		KEY[2] = 1'b1;
		repeat(50) @(posedge CLOCK_50);
		
		KEY[0] = 1'b0;
		repeat(5) @(posedge CLOCK_50);
		KEY[0] = 1'b1;
		repeat(50) @(posedge CLOCK_50);
		
		KEY[1] = 1'b0;
		repeat(5) @(posedge CLOCK_50);
		KEY[1] = 1'b1;
		repeat(50) @(posedge CLOCK_50);
		
		KEY[0] = 1'b0;
		repeat(5) @(posedge CLOCK_50);
		KEY[0] = 1'b1;
		repeat(50) @(posedge CLOCK_50);
		
		// complete a line
		repeat(10) begin
			KEY[0] = 1'b0;
			repeat(5) @(posedge CLOCK_50);
			KEY[0] = 1'b1;
			repeat(50) @(posedge CLOCK_50);
			
			KEY[2] = 1'b0;
			repeat(5) @(posedge CLOCK_50);
			KEY[2] = 1'b1;
			repeat(50) @(posedge CLOCK_50);
		end
		
		repeat(1000) @(posedge CLOCK_50);
		
		// all keys simultaneously
		KEY = 4'b0000;
		repeat(5) @(posedge CLOCK_50);
		KEY = 4'b1111;
		repeat(50) @(posedge CLOCK_50);
		
		// game over
		repeat(30) begin
			KEY[0] = 1'b0;
			repeat(5) @(posedge CLOCK_50);
			KEY[0] = 1'b1;
			repeat(50) @(posedge CLOCK_50);
		end
		
		repeat(100) @(posedge CLOCK_50);
		
		// inputs during game over state
		KEY[3] = 1'b0;
		repeat(5) @(posedge CLOCK_50);
		KEY[3] = 1'b1;
		repeat(50) @(posedge CLOCK_50);
		
		KEY[1] = 1'b0;
		repeat(5) @(posedge CLOCK_50);
		KEY[1] = 1'b1;
		repeat(50) @(posedge CLOCK_50);
		
		// reset during game over
		SW[9] = 1'b1;
		repeat(10) @(posedge CLOCK_50);
		SW[9] = 1'b0;
		repeat(10) @(posedge CLOCK_50);
		
		// restaring
		KEY[0] = 1'b0;
		repeat(5) @(posedge CLOCK_50);
		KEY[0] = 1'b1;
		repeat(50) @(posedge CLOCK_50);
		
		// combination of moves
		KEY[1] = 1'b0;
		repeat(5) @(posedge CLOCK_50);
		KEY[1] = 1'b1;
		repeat(50) @(posedge CLOCK_50);
		
		KEY[0] = 1'b0;
		repeat(5) @(posedge CLOCK_50);
		KEY[0] = 1'b1;
		repeat(50) @(posedge CLOCK_50);
		
		// move piece to boundary
		repeat(10) begin
			KEY[3] = 1'b0;
			repeat(5) @(posedge CLOCK_50);
			KEY[3] = 1'b1;
			repeat(50) @(posedge CLOCK_50);
		end
		
		repeat(10) begin
			KEY[2] = 1'b0;
			repeat(5) @(posedge CLOCK_50);
			KEY[2] = 1'b1;
			repeat(50) @(posedge CLOCK_50);
		end
		
		KEY[0] = 1'b0;
		repeat(5) @(posedge CLOCK_50);
		KEY[0] = 1'b1;
		repeat(50) @(posedge CLOCK_50);
		
		// holding keys down
		KEY[3] = 1'b0;
		repeat(5) @(posedge CLOCK_50);
		KEY[3] = 1'b1;
		repeat(50) @(posedge CLOCK_50);

		$stop;
	end
	
endmodule
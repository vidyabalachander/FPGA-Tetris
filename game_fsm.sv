module game_fsm(clk, reset, game_over, state, user);
	input logic clk, reset, user, game_over;
	output logic [1:0] state;
	
	enum logic [1:0] {home = 2'b00, play = 2'b01, over= 2'b10} ps, ns;
	
	always_comb begin
		ns = ps;
		
		case (ps)
			home: begin
				if (user)	ns = play;
			end
			play: begin
				if (game_over)		ns = over;
			end
			over: begin
				ns = ps;
			end
			
			default: ns = ps;
		endcase
	end
	
	always_ff @(posedge clk) begin
		if (reset)
			ps <= home;  
		else
			ps <= ns;
	end
	
	assign state = ps;
	 
endmodule

module game_fsm_testbench();
	logic clk, reset, user, game_over;
	logic [1:0] state;
	
	game_fsm dut (
		.clk(clk),
		.reset(reset),
		.game_over(game_over),
		.state(state),
		.user(user)
	);
	
	parameter CLOCK_PERIOD = 10;
	initial begin
		clk = 0;
		forever #(CLOCK_PERIOD/2) clk = ~clk;
	end
	
	initial begin
		reset = 1;
		user = 0;
		game_over = 0;
		repeat(2) @(posedge clk);
		
		reset = 0;
		repeat(2) @(posedge clk);
		
		// home to play
		user = 1;
		@(posedge clk);
		user = 0;
		@(posedge clk);
		repeat(3) @(posedge clk);
		
		// play to over
		game_over = 1;
		@(posedge clk);
		@(posedge clk);
		repeat(3) @(posedge clk);
		
		// nothing changes over
		user = 1;
		@(posedge clk);
		user = 0;
		@(posedge clk);
		repeat(3) @(posedge clk);
		
		// should go to home
		repeat(2) @(posedge clk);
		reset = 1;
		@(posedge clk);
		reset = 0;
		@(posedge clk);
		
		repeat(2) @(posedge clk);
		
		$stop;
	end
	
endmodule

// HOME: Returns 00 if Home is on. This tells display to put up the TETRIS home screen. Press any key to go to PLAY.
// PLAY: Returns 01 if PLAY is on. This tells display to disable the home screen and put on the board screen including the next piece. Tells other modules that they can turn on. Game_over makes the state go to OVER
// OVER: Returns 10 if OVER is high. Tells display to display game over screen. User input doesn’t matter anymore. This works because the submodules are tied to PLAY being high.

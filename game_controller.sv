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
					if (user)	ns = home;
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


// HOME: Returns 00 if Home is on. This tells display to put up the TETRIS home screen. Press any key to go to PLAY.
// PLAY: Returns 01 if PLAY is on. This tells display to disable the home screen and put on the board screen including the next piece. Tells other modules that they can turn on. Game_over makes the state go to OVER
// OVER: Returns 10 if OVER is high. Tells display to display game over screen. User input doesn’t matter anymore. This works because the submodules are tied to PLAY being high.

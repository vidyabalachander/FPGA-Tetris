module board_state ( 
	input logic clk, reset,
	input logic lock_in,
	input logic [15:0] piece_map_in,
	input logic [3:0] piece_x_in,
	input logic [3:0] piece_y_in,

	output logic [15:0][15:0] occupancy,
	output logic game_over,
	output logic [5:0] lines,

	output logic [15:0][15:0] RedPixels, 
	output logic [15:0][15:0] GrnPixels 
);

	// registers
	logic [15:0][15:0] RedPixels_r, RedPixels_n;
	logic [15:0][15:0] GrnPixels_r, GrnPixels_n;
	logic [5:0] lines_r, lines_n;
	logic game_over_r, game_over_n;

	assign occupancy = RedPixels_r;
	assign RedPixels = RedPixels_r;
	assign GrnPixels = GrnPixels_r;
	assign game_over = game_over_r;
	assign lines = lines_r;
	
	always_ff @(posedge clk or posedge reset) begin
		if	(reset) begin
			RedPixels_r <= '0;
			GrnPixels_r <= '0;
			game_over_r <= 1'b0;
			lines_r <= 6'b0;

			for (int i = 0; i < 16; i = i + 1) begin
				RedPixels_r[i][11]  <= 1'b1;  // Left Wall Red 
				RedPixels_r[i][0] <= 1'b1; 	// Right Wall Red 
				GrnPixels_r[i][11]  <= 1'b1;  // Left Wall Green 
				GrnPixels_r[i][0] <= 1'b1; 	// Right Wall Green 
			end
		end
		
		else if (lock_in) begin
			RedPixels_r <= RedPixels_n; 
			GrnPixels_r <= GrnPixels_n;
			game_over_r <= game_over_n;
			lines_r <= lines_n;
		end
	end
	
	
	always_comb begin
	logic row_is_full; 
	
	logic [5:0] lines_cleared;
	int dest_row, src_row, col, dy, dx, index;
	logic [15:0][15:0] temp_grid;
	logic [3:0] abs_x;
	logic [3:0] abs_y;
	logic block_exists;
 
	RedPixels_n = RedPixels_r;
	GrnPixels_n = GrnPixels_r;
	game_over_n = game_over_r;
	lines_n = lines_r;
	
	temp_grid = RedPixels_r; 
	lines_cleared = 6'b0;

	if (lock_in) begin
        
        for (dy = 0; dy < 4; dy = dy + 1) begin
            for (dx = 0; dx < 4; dx = dx + 1) begin
                index = 15 - (dy * 4 + dx);
					 block_exists = piece_map_in[index];
					 
					 if (block_exists) begin
						abs_x = piece_x_in + dx;
						abs_y = piece_y_in + dy;
						
						if (abs_x >= 4'd1 && abs_x <= 4'd10) begin
							temp_grid[abs_y][abs_x] = 1'b1;
							
							if (abs_y < 4'd2) begin
								game_over_n = 1'b1;
							end
						end
					end
            end
        end

        dest_row = 15; // Destination row
        
        for (src_row = 15; src_row >= 0; src_row = src_row - 1) begin

            row_is_full = 1'b1;

            // Check if the current row is full
            for (col = 1; col <= 10; col = col + 1) begin
                if (temp_grid[src_row][col] == 1'b0) begin
                    row_is_full = 1'b0;
                    break;
                end
            end

            if (row_is_full) begin
                lines_cleared = lines_cleared + 1'b1;
            end else begin
                if (dest_row != src_row) begin
                    for (col = 1; col <= 10; col = col + 1) begin
                        temp_grid[dest_row][col] = temp_grid[src_row][col];
                    end
                    // Clearing source row
                    for (col = 1; col <= 10; col = col + 1) begin
                        temp_grid[src_row][col] = 1'b0;
                    end
                end
                dest_row = dest_row - 1;
            end
        end

			RedPixels_n = temp_grid;
			GrnPixels_n = GrnPixels_r;

			// recoloring the walls
			for (int i = 0; i < 16; i = i + 1) begin
				RedPixels_n[i][11] = 1'b1;
				RedPixels_n[i][0] = 1'b1;
				GrnPixels_n[i][11] = 1'b1;
				GrnPixels_n[i][0] = 1'b1;
			end
			
			lines_n = lines_r + lines_cleared;
		end
	end
endmodule

module board_state_testbench();
	logic clk, reset;
	logic lock_in;
	logic [15:0] piece_map_in;
	logic [3:0] piece_x_in;
	logic [3:0] piece_y_in;
	logic [15:0][15:0] occupancy;
	logic game_over;
	logic [5:0] lines;
	logic [15:0][15:0] RedPixels;
	logic [15:0][15:0] GrnPixels;
	
	board_state dut (
		.clk(clk),
		.reset(reset),
		.lock_in(lock_in),
		.piece_map_in(piece_map_in),
		.piece_x_in(piece_x_in),
		.piece_y_in(piece_y_in),
		.occupancy(occupancy),
		.game_over(game_over),
		.lines(lines),
		.RedPixels(RedPixels),
		.GrnPixels(GrnPixels)
	);
	
	parameter CLOCK_PERIOD = 10;
	initial begin
		clk = 0;
		forever #(CLOCK_PERIOD/2) clk = ~clk;
	end
	
	initial begin
		reset = 1;
		lock_in = 0;
		piece_map_in = 16'h0;
		piece_x_in = 4'd0;
		piece_y_in = 4'd0;
		repeat(2) @(posedge clk);
		
		reset = 0;
		@(posedge clk);
		
		// o piece
		piece_map_in = 16'h6600;
		piece_x_in = 4'd5;
		piece_y_in = 4'd14;
		lock_in = 1;
		@(posedge clk);
		lock_in = 0;
		@(posedge clk);
		
		// i piece
		piece_map_in = 16'h00F0;
		piece_x_in = 4'd3;
		piece_y_in = 4'd13;
		lock_in = 1;
		@(posedge clk);
		lock_in = 0;
		@(posedge clk);
		
		// t piece
		piece_map_in = 16'h4E00;
		piece_x_in = 4'd7;
		piece_y_in = 4'd12;
		lock_in = 1;
		@(posedge clk);
		lock_in = 0;
		@(posedge clk);
		
		// full line at bottom
		piece_map_in = 16'h00F0;
		piece_x_in = 4'd1;
		piece_y_in = 4'd15;
		lock_in = 1;
		@(posedge clk);
		lock_in = 0;
		@(posedge clk);
		
		piece_map_in = 16'h00F0;
		piece_x_in = 4'd5;
		piece_y_in = 4'd15;
		lock_in = 1;
		@(posedge clk);
		lock_in = 0;
		@(posedge clk);
		
		piece_map_in = 16'h6600;
		piece_x_in = 4'd9;
		piece_y_in = 4'd15;
		lock_in = 1;
		@(posedge clk);
		lock_in = 0;
		@(posedge clk);
		
		// game over
		piece_map_in = 16'h6600;
		piece_x_in = 4'd5;
		piece_y_in = 4'd0;
		lock_in = 1;
		@(posedge clk);
		lock_in = 0;
		@(posedge clk);
		
		reset = 1;
		@(posedge clk);
		reset = 0;
		@(posedge clk);
		
		// clearing multiple lines
		piece_map_in = 16'h8888;
		piece_x_in = 4'd1;
		piece_y_in = 4'd12;
		lock_in = 1;
		@(posedge clk);
		lock_in = 0;
		@(posedge clk);
		
		piece_map_in = 16'h8888;
		piece_x_in = 4'd2;
		piece_y_in = 4'd12;
		lock_in = 1;
		@(posedge clk);
		lock_in = 0;
		@(posedge clk);
		
		piece_map_in = 16'h00F0;
		piece_x_in = 4'd3;
		piece_y_in = 4'd15;
		lock_in = 1;
		@(posedge clk);
		lock_in = 0;
		@(posedge clk);
		
		piece_map_in = 16'h00F0;
		piece_x_in = 4'd7;
		piece_y_in = 4'd15;
		lock_in = 1;
		@(posedge clk);
		lock_in = 0;
		@(posedge clk);
		
		repeat(3) @(posedge clk);
		$stop;
	end
	
endmodule
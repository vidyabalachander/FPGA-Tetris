module piece(clk, reset, left, right, rotate, drop, occupancy, state, piece_bitmap_out, 
	next_piece_bitmap, curr_x_out, curr_y_out, lock_out);
	input logic clk, reset;
	input logic left, right, rotate, drop;
	input logic [15:0][15:0] occupancy;
	input logic [1:0] state;
	
	logic [10:0] fall_counter;
	logic fall_tick;
	assign fall_tick = (fall_counter == 11'd1000); // adjusts speed of falling piece
	
	output logic [15:0] piece_bitmap_out;
	output logic [15:0] next_piece_bitmap;
   output logic [3:0] curr_x_out, curr_y_out; 
   output logic lock_out;
	
	logic [2:0] piece_generator;
	
	lfsr gen (.clk, .reset, .lfsr_o(piece_generator));
	
	logic [2:0] curr_piece, next_piece;     // Which piece type
	logic [1:0] curr_rotation;              // Which rotation
	logic [3:0] curr_x;                     // X location
	logic [3:0] curr_y;                     // Y location
   logic lock_flag;                    
    
	logic [2:0] curr_piece_n, next_piece_n; 
	logic [1:0] curr_rotation_n;
	logic [3:0] curr_x_n;
	logic [3:0] curr_y_n;
   logic lock_flag_n;
	
	logic lock_flag_delayed;
	
	const logic [6:0][3:0][15:0] PIECE_BITMAP = {
		// I
		{ 16'h00F0, 16'h2222, 16'h00F0, 16'h2222 }, 

		// J
		{ 16'h2260, 16'h08E0, 16'hC880, 16'hE200 },

		// L
		{ 16'h4460, 16'h7400, 16'h3110, 16'h0170 },

		// O
		{ 16'h6600, 16'h6600, 16'h6600, 16'h6600 },

		// S
		{ 16'h6C00, 16'h4620, 16'h6C00, 16'h4620 },

		// T
		{ 16'hE400, 16'h2620, 16'h04E0, 16'h8C80 },

		// Z
		{ 16'hC600, 16'h2640, 16'hC600, 16'h2640 } 
	};
	
	assign piece_bitmap_out = PIECE_BITMAP[curr_piece][curr_rotation];
	assign next_piece_bitmap = PIECE_BITMAP[next_piece][0];
	assign curr_x_out       = curr_x;
	assign curr_y_out       = curr_y;
	assign lock_out         = lock_flag_delayed;
	
	always_ff @(posedge clk or posedge reset) begin
		if (reset) begin
			curr_piece    	<= 3'd0;             			// default piece
			next_piece    	<= piece_generator % 3'd7;  	// initial next piece from LFSR
			curr_rotation 	<= 2'd0;             			// default rotation
			curr_x        	<= 4'd5;             // starting X pos
			curr_y        	<= 4'd0;             // starting Y pos
			lock_flag     	<= 1'b0;
			lock_flag_delayed <= 1'b0;
			fall_counter  	<= '0;
		end
		else begin
			if (state == 2'b01) begin // play state
				lock_flag_delayed <= lock_flag;
				lock_flag     <= lock_flag_n;
				
				if (lock_flag && !lock_flag_delayed) begin
					curr_piece    <= curr_piece;
					next_piece    <= next_piece;
					curr_rotation <= curr_rotation;
					curr_x        <= curr_x;
					curr_y        <= curr_y;
				end else begin
					curr_piece    <= curr_piece_n;
					next_piece    <= next_piece_n;
					curr_rotation <= curr_rotation_n;
					curr_x        <= curr_x_n;
					curr_y        <= curr_y_n;
				end
				
				if (fall_tick || drop || lock_flag) // resetting timer
					fall_counter <= 11'd0;
				else
					fall_counter <= fall_counter + 1'b1;
			end
		end
	end
		
	always_comb begin
		logic collides;
		logic [1:0] new_rotation;
		logic [3:0] temp_x;
		logic [1:0] temp_r;
		logic [3:0] temp_y;
		logic [3:0] final_y;
		logic [3:0] new_y;
		
		curr_piece_n    = curr_piece;
		next_piece_n    = next_piece;
		curr_rotation_n = curr_rotation;
		curr_x_n        = curr_x;
		curr_y_n        = curr_y;
		lock_flag_n     = 1'b0;

		if (lock_flag_delayed) begin 
			curr_piece_n    = next_piece;          
			next_piece_n    = piece_generator % 3'd7;
			curr_rotation_n = 2'd0;               
			curr_x_n        = 4'd5;                
			curr_y_n        = 4'd0;
		end

		else if (state == 2'b01) begin 
			temp_x = curr_x;
			temp_r = curr_rotation;

			// left movement
			if (left) begin
				check_collision(curr_x + 1, curr_y, curr_rotation, curr_piece, occupancy, collides);
				if (!collides) begin
					curr_x_n = curr_x + 1;
					temp_x = curr_x + 1;
				end
			end
    
			// right movement
			else if (right) begin
				check_collision(curr_x - 1, curr_y, curr_rotation, curr_piece, occupancy, collides);
				if (!collides) begin
					curr_x_n = curr_x - 1;
					temp_x = curr_x - 1;
				end
			end

			// rotational
			else if (rotate) begin
				new_rotation = (curr_rotation == 2'd3) ? 2'd0 : curr_rotation + 1'b1;
        
				check_collision(curr_x, curr_y, new_rotation, curr_piece, occupancy, collides);
				if (!collides) begin
					curr_rotation_n = new_rotation;
					temp_r = new_rotation;
				end
			end

			// dropping the piece
			else if (drop) begin
				final_y = curr_y;
		
				for (int y_search = 0; y_search < 16; y_search = y_search + 1) begin
					if (y_search >= curr_y) begin
						check_collision(temp_x, y_search, temp_r, curr_piece, occupancy, collides);
						if (!collides) begin
							final_y = y_search;
						end
					end
				end
				
				curr_y_n = final_y;
				lock_flag_n = 1'b1;
			end
    
			// falling motion
			if (fall_tick) begin
				new_y = curr_y + 4'd1;
        
				check_collision(temp_x, new_y, temp_r, curr_piece, occupancy, collides);
        
				if (!collides) begin
					curr_y_n = new_y;
				end else begin
					lock_flag_n = 1'b1;
				end
			end
		end
	end
	
	task automatic check_collision (
		input logic [3:0] check_x,
		input logic [3:0] check_y,
		input logic [1:0] check_rotation,
		input logic [2:0] check_piece,
		input logic [15:0][15:0] board_occupancy,
		output logic is_colliding
	);
		logic [15:0] piece_map = PIECE_BITMAP[check_piece][check_rotation];
		is_colliding = 1'b0;

		for (int dy = 0; dy < 4; dy = dy + 1) begin
			for (int dx = 0; dx < 4; dx = dx + 1) begin
            
				int index = 15 - (dy * 4 + dx); 
				logic block_exists = piece_map[index];

				if (block_exists) begin
                logic [3:0] abs_x = check_x + dx;
                logic [3:0] abs_y = check_y + dy; 
                
                if (abs_x < 4'd1 || abs_x > 4'd10) begin
                    is_colliding = 1'b1;
                    return;
                end
                
                if (abs_y >= 4'd15) begin
                    is_colliding = 1'b1;
                    return;
                end

                if (board_occupancy[abs_y][abs_x]) begin
                    is_colliding = 1'b1;
                    return;
                end
				end
        end
		end
	endtask
	
endmodule

module piece_testbench();
	logic clk, reset;
	logic left, right, rotate, drop;
	logic [15:0][15:0] occupancy;
	logic [1:0] state;
	logic [15:0] piece_bitmap_out;
	logic [15:0] next_piece_bitmap;
	logic [3:0] curr_x_out, curr_y_out;
	logic lock_out;
	
	piece dut (
		.clk(clk),
		.reset(reset),
		.left(left),
		.right(right),
		.rotate(rotate),
		.drop(drop),
		.occupancy(occupancy),
		.state(state),
		.piece_bitmap_out(piece_bitmap_out),
		.next_piece_bitmap(next_piece_bitmap),
		.curr_x_out(curr_x_out),
		.curr_y_out(curr_y_out),
		.lock_out(lock_out)
	);
	
	parameter CLOCK_PERIOD = 10;
	initial begin
		clk = 0;
		forever #(CLOCK_PERIOD/2) clk = ~clk;
	end
	
	initial begin
		reset = 1;
		left = 0;
		right = 0;
		rotate = 0;
		drop = 0;
		occupancy = '0;
		state = 2'b00;
		
		// boundaries for testing purposes
		for (int i = 0; i < 16; i++) begin
			occupancy[i][0] = 1'b1;
			occupancy[i][11] = 1'b1;
		end
		
		repeat(2) @(posedge clk);
		reset = 0;
		@(posedge clk);
		
		// play state
		state = 2'b01;
		repeat(2) @(posedge clk);
		
		// left
		left = 1;
		@(posedge clk);
		left = 0;
		repeat(2) @(posedge clk);
		
		// right
		right = 1;
		@(posedge clk);
		right = 0;
		repeat(2) @(posedge clk);
		
		// rotate
		rotate = 1;
		@(posedge clk);
		rotate = 0;
		repeat(2) @(posedge clk);
		
		// rotate
		rotate = 1;
		@(posedge clk);
		rotate = 0;
		@(posedge clk);
		rotate = 1;
		@(posedge clk);
		rotate = 0;
		repeat(2) @(posedge clk);
		
		// dropping
		drop = 1;
		@(posedge clk);
		drop = 0;
		repeat(5) @(posedge clk);
		
		// moving with obstacle
		occupancy[10][5] = 1'b1;
		occupancy[10][6] = 1'b1;
		occupancy[10][7] = 1'b1;
		
		left = 1;
		@(posedge clk);
		left = 0;
		repeat(2) @(posedge clk);
		
		drop = 1;
		@(posedge clk);
		drop = 0;
		repeat(5) @(posedge clk);
		
		// can't rotate b/c of something in the way
		occupancy[5][4] = 1'b1;
		occupancy[5][5] = 1'b1;
		occupancy[5][6] = 1'b1;
		
		rotate = 1;
		@(posedge clk);
		rotate = 0;
		repeat(2) @(posedge clk);
		
		// can't move left b/c of wall
		repeat(5) begin
			left = 1;
			@(posedge clk);
			left = 0;
			@(posedge clk);
		end
		
		repeat(5) begin
			right = 1;
			@(posedge clk);
			right = 0;
			@(posedge clk);
		end
		
		// falling
		repeat(1100) @(posedge clk);
		
		// piece dropping
		drop = 1;
		@(posedge clk);
		drop = 0;
		repeat(5) @(posedge clk);
		
		$stop;
	end
	
endmodule
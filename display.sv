module display (RedPixels_board, GrnPixels_board, curr_piece_map, curr_x, curr_y, 
	next_piece_map, RedPixels, GrnPixels);

	input logic [15:0][15:0] RedPixels_board;
	input logic [15:0][15:0] GrnPixels_board;
	input logic [15:0] curr_piece_map;
	input logic [3:0] curr_x;
	input logic [3:0] curr_y;
	input logic [15:0] next_piece_map;
	
	output logic [15:0][15:0] RedPixels;
	output logic [15:0][15:0] GrnPixels;
	
	logic [15:0][15:0] moving_piece_layer;
	logic [15:0][15:0] next_piece_layer;
	
	always_comb begin
    logic [3:0] next_x_anchor;
    logic [3:0] next_y_anchor;
    logic [3:0] abs_x, abs_y;
    logic piece_is_here, next_is_here;
    int dy, dx, index;
    
    moving_piece_layer = '0;
    next_piece_layer = '0;
    
    // Current piece rendering
    for (dy = 0; dy < 4; dy = dy + 1) begin
        for (dx = 0; dx < 4; dx = dx + 1) begin
            index = 15 - (dy * 4 + dx);
            
            if (curr_piece_map[index]) begin
                abs_x = curr_x + dx;
                abs_y = curr_y + dy;
                
                if (abs_x < 16 && abs_y < 16) begin
                    moving_piece_layer[abs_y][abs_x] = 1'b1;
                end
            end
        end
    end
    
    next_x_anchor = 4'd12;
    next_y_anchor = 4'd1;
    
    // Next piece rendering
    for (dy = 0; dy < 4; dy = dy + 1) begin
        for (dx = 0; dx < 4; dx = dx + 1) begin
            index = 15 - (dy * 4 + dx);
            
            if (next_piece_map[index]) begin
                abs_x = next_x_anchor + dx;
                abs_y = next_y_anchor + dy;
                
                if (abs_x >= 4'd12 && abs_x <= 4'd15 && abs_y >= 4'd1 && abs_y <= 4'd4) begin
                    next_piece_layer[abs_y][abs_x] = 1'b1;
                end
            end
        end
    end
    
    for (int y = 0; y < 16; y =     // Combine layers
y + 1) begin
        for (int x = 0; x < 16; x = x + 1) begin
            piece_is_here = moving_piece_layer[y][x];
            next_is_here  = next_piece_layer[y][x];
            
            GrnPixels[y][x] = piece_is_here | next_is_here | GrnPixels_board[y][x];
            RedPixels[y][x] = RedPixels_board[y][x] & ~piece_is_here & ~next_is_here;
        end
    end
end
		
endmodule

module display_testbench();
	logic [15:0][15:0] RedPixels_board;
	logic [15:0][15:0] GrnPixels_board;
	logic [15:0] curr_piece_map;
	logic [3:0] curr_x;
	logic [3:0] curr_y;
	logic [15:0] next_piece_map;
	
	logic [15:0][15:0] RedPixels;
	logic [15:0][15:0] GrnPixels;
	
	display dut (
		.RedPixels_board(RedPixels_board),
		.GrnPixels_board(GrnPixels_board),
		.curr_piece_map(curr_piece_map),
		.curr_x(curr_x),
		.curr_y(curr_y),
		.next_piece_map(next_piece_map),
		.RedPixels(RedPixels),
		.GrnPixels(GrnPixels)
	);
	
	initial begin
		RedPixels_board = '0;
		GrnPixels_board = '0;
		
		// o at 5, 2
		curr_piece_map = 16'h6600;
		curr_x = 4'd5;
		curr_y = 4'd2;
		next_piece_map = 16'h00F0;
		#10;
		
		// i at 3, 5
		curr_piece_map = 16'h00F0;
		curr_x = 4'd3;
		curr_y = 4'd5;
		next_piece_map = 16'h6600;
		#10;
		
		// t at 7, 0
		curr_piece_map = 16'h4E00;
		curr_x = 4'd7;
		curr_y = 4'd0;
		next_piece_map = 16'h8E00;
		#10;
		
		// board
		RedPixels_board[10][5] = 1'b1;
		GrnPixels_board[10][5] = 1'b1;
		curr_piece_map = 16'h6600;
		curr_x = 4'd5;
		curr_y = 4'd8;
		#10;
		
		// boundary piece
		curr_piece_map = 16'h00F0;
		curr_x = 4'd0;
		curr_y = 4'd0;
		#10;
		
		$stop;
	end
	
endmodule
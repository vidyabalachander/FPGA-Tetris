module series_ff (clk, d, q);
	input logic clk, d;
	output logic q;
	
	logic q1;
	
	always_ff @(posedge clk) begin
		q1 <= d;
		q <= q1;
	end
endmodule
module userInput (clk, reset, B, P);
	input logic clk, reset;
	input logic B; // button, B=1 if pressed, B=0 if not pressed
	output logic P; //pressed
	
	enum {none, pressed, held} ps, ns;
	
	always_comb begin
		ns = ps;
		
			case (ps)
				none: begin
					if (B)	ns = pressed;
					else		ns = ps;
				end
            pressed: begin
					if (B)	ns = held;
					else		ns = none;
            end
            held: begin
					if (B)	ns = ps;
					else 		ns = none;
            end
				
				default: ns = ps;
         endcase
	end
	
	always_ff @(posedge clk) begin
		if (reset)
			ps <= none;
		else
			ps <= ns;
	end
	
	assign P = (ps == pressed);
	 
endmodule

module userInput_testbench();
	logic CLOCK_50;
   logic reset;
   logic B;
	logic result;
	
	userInput dut (.clk(CLOCK_50), .reset(reset), .B(B), .P(result));

	parameter CLOCK_PERIOD=100;
	initial begin
		CLOCK_50 <= 0;
		forever #(CLOCK_PERIOD/2) CLOCK_50 <= ~CLOCK_50;
	end
	
	initial begin
		// start in reset to init state
		reset = 1;
		B     = 0;                   // not pressed (remember: DUT expects active-HIGH)
		repeat (2) @(posedge CLOCK_50);

		reset = 0;
		repeat (2) @(posedge CLOCK_50);

		// Press & hold (should produce EXACTLY one pulse on result)
		B = 1;  repeat (4) @(posedge CLOCK_50);  // press (active-high)
		B = 0;  repeat (3) @(posedge CLOCK_50);  // release

		// Another press
		B = 1;  repeat (3) @(posedge CLOCK_50);
		B = 0;  repeat (3) @(posedge CLOCK_50);

		// Reset mid-run
		reset = 1; @(posedge CLOCK_50);
		reset = 0; @(posedge CLOCK_50);

		// One more press
		B = 1;  repeat (2) @(posedge CLOCK_50);
		B = 0;  repeat (2) @(posedge CLOCK_50);

		$stop;
	end
endmodule

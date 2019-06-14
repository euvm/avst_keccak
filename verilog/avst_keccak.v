module avst_keccak(clk, reset, data_in, end_in, valid_in, ready_in,
		   data_out, end_out, valid_out, ready_out);

   input 	clk;
   input 	reset;

   input [7:0] 	data_in;
   input 	end_in;
   input 	valid_in;
   output 	ready_in;

   output [7:0] data_out;
   output 	end_out;
   output 	valid_out;
   input 	ready_out;
		
   reg 		in_ready; // To dut of keccak.v
   // reg 		stage; // toggles to 1 once the output is ready
   reg 		valid_out;
   reg 		end_out;

   reg [6:0] 	count_out; 
   
   reg 		ready_in; 
   wire 	buffer_full; // From dut of keccak.v
   wire [511:0] out; // From dut of keccak.v
   wire 	out_ready; // From dut of keccak.v
   
   reg [7:0] 	out_reg;

   wire [7:0] 	data_out;

   wire 	ready_in_1;

   assign data_out = out_reg;
   assign ready_in_1 = end_out | ((~ end_in) & ready_in);
   
   always @(posedge clk)
      if (reset)
	ready_in <= 1;
      else
	ready_in <= ready_in_1;

   always @(posedge clk) begin
      if(reset) begin
	 out_reg <= 0;
	 count_out <= 0;
	 valid_out <= 0;
	 end_out <= 0;
      end
      else if (out_ready == 1) begin
	 if (ready_out) begin
	    if (count_out == 'h40) begin
	       count_out <= 0;
	       valid_out <= 0;
	       end_out <= 1;
	    end
	    else begin
	       out_reg[7] <= out[511 - (count_out << 3)];
	       out_reg[6] <= out[510 - (count_out << 3)];
	       out_reg[5] <= out[509 - (count_out << 3)];
	       out_reg[4] <= out[508 - (count_out << 3)];
	       out_reg[3] <= out[507 - (count_out << 3)];
	       out_reg[2] <= out[506 - (count_out << 3)];
	       out_reg[1] <= out[505 - (count_out << 3)];
	       out_reg[0] <= out[504 - (count_out << 3)];
	       if (count_out == 'h00) begin
		  valid_out <= 1;
	       end
	       count_out <= count_out + 1;
	    end
	 end
      end
   end

   keccak dut (
	       .in			(data_in[7:0]),
	       .clk			(clk),
	       .reset			(reset),
	       .in_ready		(valid_in),
	       .is_last			(end_in),
	       /*AUTOINST*/
	       // Outputs
	       .buffer_full		(buffer_full),
	       .out			(out[511:0]),
	       .out_ready		(out_ready));
	       // Inputs
endmodule
  

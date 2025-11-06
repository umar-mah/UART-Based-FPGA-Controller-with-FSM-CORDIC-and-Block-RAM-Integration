module tb_ram_ip;

	logic clk;
	logic [11:0] address; 
	logic [15:0] data_in;
	logic [15:0] data_out;
	logic write_enable;

	blk_mem_gen_0 dut (
		.clka(clk),
		.ena(1'b1),          
		.wea(write_enable),  
		.addra(address),     
		.dina(data_in),      
		.douta(data_out)     
	);

	initial begin
		clk = 0;
		forever #5 clk = ~clk;
	end


	initial begin
		address = 12'h000; 
		data_in = 16'hABCD;
		write_enable = 1; 

		$display("At time %0t: Initializing signals. address=%h, data_in=%h, write_enable=%b", $time, address, data_in, write_enable);

		@(posedge clk);
		$display("At time %0t: After first posedge clk. Write 1 attempt.", $time);

		// Data is 16'hABCD, address is 12'h000
		@(posedge clk);
		$display("At time %0t: After second posedge clk. Write 2 attempt.", $time);

		address = 12'h005;
		data_in = 16'h1234;
		$display("At time %0t: Setting address=%h, data_in=%h for Write 2.", $time, address, data_in);


		@(posedge clk);
		$display("At time %0t: After third posedge clk. Turning off write_enable.", $time);

		write_enable = 0;
		$display("At time %0t: write_enable set to %b.", $time, write_enable);


		// Read address 000
		address = 12'h000;
		$display("At time %0t: Setting address=%h for Read 1.", $time, address);

		@(posedge clk); 
		$display("At time %0t: After posedge clk (1st read wait). douta=%h", $time, data_out);

		@(posedge clk);
		$display("At time %0t: After posedge clk (2nd read wait). douta=%h", $time, data_out);

		@(posedge clk);
		$display("At time %0t: After posedge clk (3rd read wait). douta=%h", $time, data_out);

		// Displayd the read data
		$display("At time %0t: Read Data at Address 0x000 = %h", $time, data_out);

		//Read address 005
		address = 12'h005; 
		$display("At time %0t: Setting address=%h for Read 2.", $time, address);

		@(posedge clk); 
		$display("At time %0t: After posedge clk (1st read wait). douta=%h", $time, data_out);

		@(posedge clk); 
		$display("At time %0t: After posedge clk (2nd read wait). douta=%h", $time, data_out);

		@(posedge clk); 
		$display("At time %0t: After posedge clk (3rd read wait). douta=%h", $time, data_out);

		// Displays the read data
		$display("At time %0t: Read Data at Address 0x005 = %h", $time, data_out);

		#20;
		$finish;

	end

endmodule

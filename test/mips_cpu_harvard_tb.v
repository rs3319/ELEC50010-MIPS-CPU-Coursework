module mips_cpu_harvard_tb;
	timeunit 1ns / 10ps;

	parameter RAM_INIT_FILE = "";
	parameter TIMEOUT_CYCLES = 100;
	parameter REF_FILE = "";
	logic OUTPUT;
	logic clk;
	logic rst;
	logic clk_enable;
	logic active;
	logic[31:0] register_v0;
	logic[31:0] data_address;
	logic[31:0] instr_address;
	logic data_write;
	logic data_read;
	logic[31:0] data_writedata;
	logic[31:0] instr_readdata;
	logic[31:0] data_readdata;
	integer data_file;
	integer scan_file;
	mips_cpu_iMemory #(RAM_INIT_FILE) iMemory(instr_address,instr_readdata);
	mips_cpu_dMemory dMemory(clk,data_address,data_write,data_read,data_writedata,data_readdata);
	mips_cpu_harvard harvardCpu(clk,rst,active,register_v0,clk_enable,instr_address,instr_readdata,data_address,data_write,data_read,data_writedata,data_readdata);

	initial begin
		clk = 0;
		repeat(TIMEOUT_CYCLES) begin
			#10
			clk = !clk;
			#10
			clk = !clk;
		end

		$fatal(2,"CPU Timed Out, Infinite Loop",TIMEOUT_CYCLES);
	end

	initial begin
		rst <= 0;
		clk_enable <= 1;
		@(posedge clk);
		rst <= 1;
		@(posedge clk);
		rst <= 0;
		@(posedge clk);
		assert(active==1);
		else $display("CPU signal active != 1 after reset");


		while(active) begin
		 @(posedge clk);
		 //$display("instr_address : %32h, instr_readdata : %32h",instr_address,instr_readdata);
		end
		$display("Register V0: ",register_v0);
		$display("Finished Running");
		//scan_file = $fscanf(REF_FILE, "%d\n", OUTPUT);
		if(register_v0 != 0) begin
			$fatal(1,"Reference Outputs do not match Testbench Output: ", register_v0);
		end
		$finish;
	end

endmodule






module mips_cpu_dMemory(
	input logic clk,
	input logic[31:0] address,
	input logic write,
	input logic read,
	input logic[31:0] writedata,
	output logic[31:0] readdata
);

	parameter MEM_INIT_FILE = "";

	reg[31:0] memory [4294967295:0];

	inital begin
		integer i;
		for (i = 0;i<4294967296;i++) begin
			memory[i] = 0;
		end

		if (MEM_INIT_FILE != "") begin
			$readmemh(MEM_INIT_FILE, memory);
		end
	end

	assign readdata = memory[address];

	always @(posedge clk) begin
		if(write) begin
			memory[address] <= writedata;
		end
	end
endmodule
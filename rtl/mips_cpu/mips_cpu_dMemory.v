module mips_cpu_dMemory(
	input logic clk,
	input logic[31:0] address,
	input logic write,
	input logic read,
	input logic[31:0] writedata,
	output logic[31:0] readdata
);



	reg[7:0] memory [536870911:0];

	initial begin
		integer i;
		for (i = 0;i<536870912;i++) begin
			memory[i] = 0;
		end

	end

	assign readdata[7:0] = memory[address];
	assign readdata[15:8] = memory[address+1];
	assign readdata[23:16] = memory[address+2];
	assign readdata[31:24] = memory[address+3];

	always @(posedge clk) begin
		if(write) begin
			memory[address] <= writedata[7:0];
			memory[address+1] <= writedata[15:8];
			memory[address+2] <= writedata[23:16];
			memory[address+3] <= writedata[31:24];
		end
	end
endmodule

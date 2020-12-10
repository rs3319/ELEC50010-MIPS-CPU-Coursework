module mips_cpu_iMemory(
	input logic[31:0] read_address,
	output logic[31:0] readdata
);

	parameter MEM_INIT_FILE = "";


	logic[7:0] memory [400:0];
	logic[31:0] address;
	assign address = read_address - $unsigned(32'hBFC00000);
	initial begin
		integer i;
		for(i = 0;i< 401;i++) begin
			memory[i] = 0;
		end
		if (MEM_INIT_FILE != "") begin
			$readmemh(MEM_INIT_FILE, memory, 0, 400);
		end
	end

	assign readdata[7:0] = memory[address];
	assign readdata[15:8] = memory[address+1];
	assign readdata[23:16] = memory[address+2];
	assign readdata[31:24] = memory[address+3];

endmodule
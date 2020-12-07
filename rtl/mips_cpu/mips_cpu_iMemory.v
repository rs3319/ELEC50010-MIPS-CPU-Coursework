module mips_cpu_iMemory(
	input logic[31:0] address,
	output logic[31:0] readdata
);

	parameter MEM_INIT_FILE = "";


	logic[7:0] memory [4294967296:0];

	initial begin

		if (MEM_INIT_FILE != "") begin
			$readmemh(MEM_INIT_FILE, memory, $unsigned(32'hBCF00000),$unsigned(32'hFFFFFFFF));
		end
	end

	assign readdata[7:0] = memory[address];
	assign readdata[15:8] = memory[address+1];
	assign readdata[23:16] = memory[address+2];
	assign readdata[31:24] = memory[address+3];

endmodule
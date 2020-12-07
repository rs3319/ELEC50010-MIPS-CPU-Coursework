module mips_cpu_iMemory(
	input logic[31:0] address,
	output logic[31:0] readdata
);

	parameter MEM_INIT_FILE = "";


	reg[7:0] memory [536870911:0];

	initial begin

		if (MEM_INIT_FILE != "") begin
			$readmemh(MEM_INIT_FILE, memory, $unsigned(32'h179E0000),$unsigned(32'h1FFFFFFF));
		end
	end

	assign readdata[7:0] = memory[address];
	assign readdata[15:8] = memory[address+1];
	assign readdata[23:16] = memory[address+2];
	assign readdata[31:24] = memory[address+3];

endmodule
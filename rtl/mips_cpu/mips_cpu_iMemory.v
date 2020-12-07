module mips_cpu_iMemory(
	input logic[31:0] address,
	output logic[31:0] readdata
);

	parameter MEM_INIT_FILE = "";

	reg[31:0] memory[4294967295:0];

	initial begin
		integer i;
		for (i = 0;i<4294967296;i++) begin
			memory[i] = 0;
		end


		if (MEM_INIT_FILE != "") begin
			$readmemh(MEM_INIT_FILE, memory, 32'hBCF00000);
		end
	end

	assign readdata = memory[address];

endmodule
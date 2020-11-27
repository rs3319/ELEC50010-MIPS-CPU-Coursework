module mips_cpu_harvard(
    
    input logic clk,
    input logic reset,
    output logic active,
    output logic[31:0] register_v0,
    
    input logic clk_enable,
    
    output logic[31:0] instr_address,
    input logic[31:0] instr_readdata,
    
    output logic[31:0] data_address,
    output logic data_write,
    output logic data_read,
    output logic[31:0] data_writedata,
    input logic[31:0] data_readdata
);

typedef enum logic[2:0] {
	FETCH = 3'b000,
	EXEC = 3'b001,
	MEM_READ = 3'b010
	WRITE_BACK = 3'b011,
	HALTED = 3'b100
} state_t




	logic[2:0] state;
	logic[31:0] pc, pc_next;
	assign pc_next = pc + 1;
	logic[31:0] instr;

// Reg Signals
 	logic[4:0] read_index_rs;
 	logic[31:0] read_data_rs;
	logic[4:0] read_index_rt;
	logic[31:0] read_data_rt;
 	logic[4:0] write_index;
	logic write_enable;
	logic[31:0] write_data;


// ALU Signals
	logic[2:0] AluOP;
	logic AluSrc;
	logic[31:0] Alu_A;
	assign Alu_A = read_data_rs;
	logic[31:0] Alu_B;
	assign Alu_B = AluSrc ? instr[15:0] : read_data_rt;
	logic[31:0] Alu_Out;

// Reg Write Back Multiplexer
	logic Mem_Reg_Select;
	logic RegDst;

// Conditional Branches
	logic Branch;
	logic Jump;	



initial begin
	state = HALTED;
	running = 0;
end

always @(posedge clk) begin
	if (rst) begin
		// reset code, change state to FETCH
	end
	else if(clk_enable) begin
		case(state)
		FETCH: begin //Fetching Instruction

			   end	
		EXEC:		 //Reading Reg Values
               begin

               end   				
		MEM_READ:	// Reading/Writing to Memory
				begin

				end
		WRITE_BACK: // Reg/Memory to Reg (Increment PC here)
				begin
					pc <= pc_next;
				end
		default: // do nothing
	end
end
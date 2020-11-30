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

typedef enum logic[1:0] {
	FETCH = 2'b00,
	DECODE = 2'b01,
	EXEC = 2'b10
	HALTED = 2'b11
} state_t
typedef enum logic[6:0] {
	OP_R = 7'b0000000,

} opcode_t



	logic[2:0] state;
	logic[31:0] pc, pc_next;
	assign pc_next = pc + 4;
	logic[31:0] instr;
	assign instr_address = pc;
	logic[5:0] opcode;

// Reg Signals
 	logic[4:0] read_index_rs;
 	logic[31:0] read_data_rs;
	logic[4:0] read_index_rt;
	logic[31:0] read_data_rt;
 	logic[4:0] write_index;
 	logic write_on_next;
	logic write_enable;
	logic[31:0] write_data;

// Intermediate Reg Signals
	logic[4:0] Rt;
	logic[4:0] Rd;


// ALU Signals
	logic[5:0] AluOP;
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
	logic Jump;	// flag for jumping, set to 1 on the branch instruction but only check the logic after the next instruction (for the delay slot)
	logic jump_on_next;
	logic[31:0] Branch_Addr; // Store branch address for delay slot, branch after next instruction is complete
	logic[31:0] Link_Addr;


initial begin
	state = HALTED;
	running = 0;
end

always @(posedge clk) begin
	if (rst) begin
		// reset code, change state to FETCH
		pc <= 0;
		state <= FETCH;
	end
	else if(clk_enable) begin
		case(state)
		FETCH: begin //Fetching Instruction and Decode
				//Reading Reg Values
				instr <= instr_readdata;
				data_read <= 0;
               	data_write <= 0;
				read_index_rs <= instr_readdata[25:21];
				read_index_rt <= instr_readdata[20:16];
				if(instr_readdata[31:26] == 6'b000000) begin
					write_index <= instr_readdata[15:11];
					AluSrc <= 1;
				end
				else begin
					AluSrc <= 0;
					write_index <= instr_readdata[20:16];
				end

				 //Get ALUOp
				state <= EXEC;
			   end	
		DECODE: // Read from Memory (1 cycle delay needed to evaluate Rs before hand)
               begin
               //Get memory address 
               
               case(opcode)
               		O_Jump:	 begin
               				 Branch_Addr <= pc + 4*instr[25:0] + 4;
               				 Jump <= 1;
               				 end
               		O_Addiu: begin
               				 AluOp <= 0; //Implement AluOp
               				 write_on_next <= 1;
               				 end
               		O_Lw: begin
               			  data_address <= 4*(read_data_rs + instr[15:0]);
               			  data_read <= 1;
               			  data_write <= 0;
               			  write_on_next <= 1;
               			  mem_reg_select <= 0;
               			  end
               		O_Sw: begin
               			  data_address <= 4*(read_data_rs + instr[15:0]);
               			  data_writedata <= read_data_rt;
               			  data_write <= 1;
               			  data_read <= 0;
               			  end


               state <= EXEC;
               end   				
		EXEC: // Write to Reg/Memory (Increment PC here)
				begin
				// Memory/Reg -> Reg
				if(!mem_reg_select) begin
					write_data <= data_readdata;
				end
				else begin
					write_data <= Alu_Out;
				end
				// Reg -> Memory
				if(write_on_next) begin
					write_enable <= 1;
					write_on_next <= 0;
				end
				else begin
					write_enable <= 0;
				end
				if(delay_slot) begin
					pc <= Branch_Addr;
					Branch <= 0;
					Jump <= 0;
					delay_slot <= 0;
				end
				else if(Branch | Jump) begin
				  	delay_slot <= 1;
				  	pc <= pc_next;
				end
				else begin
					pc <= pc_next;
				end
				state <= FETCH;
				end
		default: // do nothing
	end
end
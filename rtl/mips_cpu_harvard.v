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
	EXEC = 2'b10,
	HALTED = 2'b11
} state_t;
typedef enum logic[5:0] { 
	OP_R = 6'b000000,
	OP_BLTZ = 6'b000001,
	OP_JUMP = 6'b000010,
	OP_JAL = 6'b000011,
	OP_BEQ = 6'b000100,
	OP_BNE = 6'b000101,
	OP_BLEZ = 6'b000110,
	OP_BGTZ = 6'b000111,
	OP_ADDIU = 6'b001001,
	OP_SLTI = 6'b001010,
	OP_SLTIU = 6'b001011,
	OP_ANDI = 6'b001100,
	OP_ORI = 6'b001101,
	OP_XORI = 6'b001110,
	OP_LUI = 6'b001111,
	OP_LB = 6'b100000,
	OP_LH = 6'b100001,
	OP_LWL = 6'b100010,
	OP_LW = 6'b100011,
	OP_LBU = 6'b100100,
	OP_LHU = 6'b100101,
	OP_LWR = 6'b100110,
	OP_SB = 6'b101000,
	OP_SH = 6'b101001,
	OP_SW = 6'b101011
} opcode_t;

typedef enum logic[5:0]{
	// add identifiers for alu functions
	F_SLL = 6'b000000,
	F_SRL = 6'b000001,
	F_SRA = 6'b000011,
	F_SLLV = 6'b000100,
	F_SRLV = 6'b000110,
	F_SRAV = 6'b000111,
	F_JR = 6'b001000,
	F_JALR = 6'b001001,
	F_MFHI = 6'b010000,
	F_MTHI = 6'b010001,
	F_MFLO = 6'b010010,
	F_MTLO = 6'b010011,
	F_MULT = 6'b011000,
	F_MULTU = 6'b011001,
	F_DIV = 6'b011010,
	F_DIVU = 6'b011011,
	F_ADD = 6'b100000,
	F_ADDU = 6'b100001,
	F_SUB = 6'b100010,
	F_SUBU = 6'b100011,
	F_AND = 6'b100100,
	F_OR = 6'b100101,
	F_XOR = 6'b100110,
	F_NOR = 6'b100111,
	F_SLT = 6'b101010,
	F_SLTU = 6'b101011
} AluOP_t;


	logic[1:0] state;
	logic[31:0] pc, pc_next;
	assign pc_next = pc + 4;
	logic[31:0] instr;
	assign instr_address = pc;
	logic[5:0] opcode;
	assign opcode = instr_readdata[31:26];

// Reg Signals
 	logic[4:0] read_index_rs;
 	logic[31:0] read_data_rs;
	logic[4:0] read_index_rt;
	logic[31:0] read_data_rt;
 	logic[4:0] write_index;
 	logic write_on_next;
	logic reg_write_enable;
	logic[31:0] reg_write_data;
	logic carryReg;
	logic carryNext;
	logic linkNext;
	logic[31:0] Debug;
// Intermediate Reg Signals
	logic[4:0] Rt;
	logic[4:0] Rd;
// LWL LWR Intermediate Signals
	logic [31:0] lw_shift;

// ALU Signals
	logic[5:0] AluOP;
	assign AluOP = instr[5:0];
	logic[31:0] Alu_A;
	assign Alu_A = read_data_rs;
	logic[31:0] Alu_B;
	assign Alu_B = read_data_rt;
	logic[15:0] Alu_Immediate;
	assign Alu_Immediate = instr[15:0];
	logic[4:0] Alu_Shamt;
	assign Alu_Shamt = instr[10:6];
	logic[31:0] Alu_Out;
	logic ZF;

// HiLo
	logic DivFlag;
	logic Div_Valid_Out;
	logic Div_Reg;
	logic Div_Valid_In;
	logic HiLoSrc;
	logic HiLoSel;
	logic [31:0] HiLoOut;
	logic [31:0] HiOut;
	logic [31:0] LoOut;
	assign HiLoOut = HiLoSel ? HiOut : LoOut;
// Reg Write Back Multiplexer
	logic Mem_Reg_Select;
	logic RegDst;

// Conditional Branches
	logic Branch;
	logic sig_Branch;
	logic Jump;	// flag for jumping, set to 1 on the branch instruction but only check the logic after the next instruction (for the delay slot)
	logic jump_on_next;
	logic[31:0] Branch_Addr; // Store branch address for delay slot, branch after next instruction is complete
	logic[31:0] Link_Addr;
	logic delay_slot;

initial begin
	state = HALTED;
	active = 0;
end

always @(posedge clk) begin
	if (reset) begin
		// reset code, change state to FETCH
		data_read <= 0;
		DivFlag <= 0;
		data_write <= 0;
		pc <= 32'hBFC00000;
		active <= 1;
		state <= FETCH;
	    end
	else if(clk_enable) begin
		case(state)
		FETCH: begin //Fetching Instruction and Decode
				//Reading Reg Values
				//$monitor("Fetching : Opcode: %6b, Instr Address : %32h",opcode,instr_address);
				instr <= instr_readdata;
				data_read <= 0;
               	data_write <= 0;
				Jump <= 0;
				Branch <= 0;
               	write_on_next <= 0;
               	reg_write_enable <= 0;
               	HiLoSrc <= 0;
               	Div_Reg <= 0;
				read_index_rs <= instr_readdata[25:21];
				read_index_rt <= instr_readdata[20:16];
				if(instr_readdata[31:26] == 6'b000000) begin
					write_index <= instr_readdata[15:11];
				end
				else begin
					write_index <= instr_readdata[20:16];
				end
				if(pc == 0) begin
					active <= 0;
					state <= HALTED;
				end
				else begin
					state <= DECODE;
				end
			  	end	
		DECODE: // Read from Memory (1 cycle delay needed to evaluate Rs before hand)
               begin
               //Get memory address 
               //$monitor("Decoding");
               case(opcode)

               		OP_JUMP: begin
               				 Branch_Addr <= {pc_next[31:28],instr[25:0],2'b00};
               				 //$monitor("Branch: %32h",Branch_Addr);
               				 Jump <= 1;
               				 end
               		OP_R: begin
               			//$monitor("R type: %6b",AluOP);
	               		case(AluOP) 
	               		
	               		 F_ADDU, F_SUBU, F_AND, F_OR, F_XOR, F_SRA, F_SRL, F_SLL, F_SLT, F_SLTU: begin
	               				Mem_Reg_Select <= 1;
	               		 		write_on_next <= 1;
	               		 	end
	               		
	   
	               		 F_JR: begin
	               		 		//monitor("Register Rs: %32h Read data rs: %32h",read_index_rs, read_data_rs);
	               		 		Branch_Addr <= read_data_rs;
	               		 		Jump <= 1;
	               		 		end
	               		 F_JALR:
	               		 		begin
	               		 			Mem_Reg_Select <= 1;
	               		 			reg_write_data <= pc_next + 4;
	               		 			Jump <= 1;
	               		 			write_on_next <= 1;
	               		 			Branch_Addr <= read_data_rs;
	               		 		end
	               		 F_MULTU,F_MULT:
	               		 		begin
	               		 			//$monitor("Multiplication")
	               		 		end
	               		 F_MFHI:
	               		 		begin
	               		 			Mem_Reg_Select <= 1;
	               		 			write_on_next <= 1;
	               		 			HiLoSel <= 1;
	               		 			HiLoSrc <= 1;
	               		 			//$monitor("Debug: Hi : %32h Lo : %32h",HiOut,LoOut);
	               		 		end
	               		 F_MFLO:
	               		 		begin
	               		 			Mem_Reg_Select <= 1;
	               		 			write_on_next <= 1;
	               		 			HiLoSel <= 0;
	               		 			HiLoSrc <= 1;
	               		 			//$monitor("Debug: Hi : %32h Lo : %32h",HiOut,LoOut);
	               		 		end
	               		 F_DIV, F_DIVU:
	               		 		begin
	               		 			if(Div_Reg) begin
	               		 				//$monitor("Division Complete");
	               		 				DivFlag <= 0;
	               		 			end
	               		 			else if(!DivFlag) begin
	               		 				//$monitor("Division Begins");
	               		 				DivFlag <= 1;
	               		 				Div_Valid_In <= 1;
	               		 			end
	               		 			else begin
	               		 				//$monitor("Dividing");
	               		 				if(Div_Valid_In) begin
	               		 					Div_Valid_In <= 0;
	       								end
	       								Div_Reg <= Div_Valid_Out;
	               		 			end	
	               		 		end
	               		endcase
               		end
               		OP_JAL:
               			begin
               				Mem_Reg_Select <= 1;
               				write_index <= 31;
               				reg_write_data <= pc_next + 4;
	               		 	Jump <= 1;
	               		 	write_on_next <= 1;
	               		 	Branch_Addr <= {pc_next[31:28],instr[25:0],2'b00};
	               		 end
               		OP_ADDIU, OP_ANDI, OP_LUI, OP_ORI, OP_SLTI, OP_SLTIU:
               			begin
               				Mem_Reg_Select <= 1;
               		 		write_on_next <= 1;
               		 	end
               		OP_LW, OP_LH, OP_LHU, OP_LB, OP_LBU: begin
               			// Note for LW/SW: The effective address must be naturally aligned, If either of the two least-significant bits of the address are non-zero, an Address exception error occurs
               			  data_address <= read_data_rs + {{16{instr[15]}},instr[15:0]};

               			  data_read <= 1;
               			  data_write <= 0;
               			  write_on_next <= 1;
               			  Mem_Reg_Select <= 0;
               			  end
               		OP_LWL, OP_LWR: begin
               			  data_address <= (read_data_rs + {{16{instr[15]}},instr[15:0]}) & 32'hFFFFFFFC;
               			  //$monitor("data addr %32h",data_address);
               			  data_read <= 1;
               			  lw_shift <= (((read_data_rs + instr[15:0]) & 32'h3));
               			  data_write <= 0;
               			  write_on_next <= 1;
               			  Mem_Reg_Select <= 0;
               		end
               		OP_SW: begin

               			  data_address <= read_data_rs + {{16{instr[15]}},instr[15:0]};
               			  data_writedata <= read_data_rt;
               			  data_write <= 1;
               			  data_read <= 0;
               			  end

               		OP_BEQ, OP_BNE: begin
               			write_on_next <= 0;
               			Branch <= sig_Branch;
               		end 
               		OP_BLTZ, OP_BGTZ, OP_BLEZ: begin
						   //$monitor(read_index_rs);
               			Branch <= sig_Branch;
               			if(linkNext) begin
							   //$monitor("pc_next = %32h", pc_next);
               				Mem_Reg_Select <= 1;
               				write_index <= 31;
               				write_on_next <= 1;
               				reg_write_data <= pc_next + 4;
               			end
               		end
               endcase
               		if(!DivFlag) begin		
               			state <= EXEC;
               		end
               end   				
		EXEC: // Write to Reg/Memory (Increment PC here)
			begin
				if(!DivFlag) begin
					//$monitor("3 : Instruction: %32h, Instr Address : %32h",instr_readdata,instr_address);
					carryReg <= carryNext;	
					// Memory/Reg -> Reg
					if(!Mem_Reg_Select) begin

						case(opcode)
							OP_LW: begin	
								reg_write_data <= data_readdata;
							end
							OP_LH: begin
								reg_write_data <= {{16{data_readdata[15]}},data_readdata[15:0]};
							end
							OP_LHU: begin
								reg_write_data <= {{16{1'b0}},data_readdata[15:0]};
							end
							OP_LB: begin
								reg_write_data <= {{24{data_readdata[7]}},data_readdata[7:0]};
							end
							OP_LBU: begin
								reg_write_data <= {{24{1'b0}},data_readdata[7:0]};
							end
							OP_LWL: begin
								//$monitor("%32h, %32h",read_data_rt, opcode);
								reg_write_data <= (read_data_rt & (32'hFFFFFFFF >> ((lw_shift+1) << 3))) + ((data_readdata << ((3-lw_shift) << 3)));
							end
							OP_LWR: begin
								reg_write_data <= (read_data_rt & (32'hFFFFFFFF << ((4-lw_shift) << 3))) + (data_readdata >> ((lw_shift) << 3));
							end
						endcase
					end
					else begin
						if(HiLoSrc) begin
							reg_write_data <= HiLoOut;
						end
						else if (!Branch && !Jump) begin
							reg_write_data <= Alu_Out;
						end
					end
					// Reg -> Memory
					if(write_on_next) begin
						reg_write_enable <= 1;
						write_on_next <= 0;
					end
					else begin
						reg_write_enable <= 0;
					end
					if(delay_slot) begin
						//$monitor("Jumping to : %32h", Branch_Addr);
						pc <= Branch_Addr;
						Jump <=0;
						Branch <= 0;
						delay_slot <= 0;
					end
					else if(Branch | Jump) begin
					  	delay_slot <= 1;
					  	pc <= pc_next;
					end
					else begin
						pc <= pc_next;
					end
					if(Branch) begin
						Branch_Addr <= pc_next + {{14{Alu_Immediate[15]}},Alu_Immediate,2'b00};
					end
					state <= FETCH;
				end
				else begin
					state <= DECODE;
				end
			end
		endcase

		end
	end 


mips_cpu_ALU ALU(AluOP,opcode,Alu_Shamt,Alu_Immediate,read_data_rs,read_data_rt,carryReg,read_index_rt,sig_Branch,Alu_Out,carryNext,ZF,linkNext);
mips_cpu_regs Regs(clk,reset,read_index_rs,read_data_rs,read_index_rt,read_data_rt,write_index,reg_write_enable,reg_write_data,register_v0);
mips_cpu_hilo hilo(AluOP,clk,reset,read_data_rs,read_data_rt,Div_Valid_In,Div_Valid_Out,LoOut,HiOut);

endmodule
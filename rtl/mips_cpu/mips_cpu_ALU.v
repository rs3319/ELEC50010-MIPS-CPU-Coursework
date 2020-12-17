module mips_cpu_ALU(
	
	input logic[5:0] ALU_control,
	input logic[5:0] opcode,
	input logic[4:0] shamt, 
	input logic[15:0] immediate,
	input logic[31:0] rs_content, 
	input logic[31:0] rt_content, 
    input logic carry_in,
	input logic[4:0] rt_index, 
	
	output logic sig_branch, 
	output logic[31:0] ALU_result, 
    output logic carry_out, 
    output logic zero,
	output logic link
);	

	integer i; 
	logic[31:0] temp;
	logic[31:0] signExtend;
	logic[31:0] zeroExtend; 

	always@(*) begin		
		
		// R-type instructions
		if(opcode == 6'h0) begin
			
			case(ALU_control)
				
				6'h21 : //addu
					ALU_result = rs_content + rt_content;
					
				6'h23 : //subu
					ALU_result = rs_content - rt_content;
					
				6'h24 : //and
					ALU_result = rs_content & rt_content;
					
				6'h25 : //or
					ALU_result = rs_content | rt_content;
				
				6'h26 : //xor
					ALU_result = rs_content ^ rt_content;
					
				6'h03 : //sra
					begin
						temp = rt_content;
						for(i = 0; i < shamt; i = i + 1) begin
							temp = {temp[31],temp[31:1]}; //add the lsb for msb
						end
					
					ALU_result = temp;
					end
				
				6'h07 : //srav
					begin
						temp = rt_content;
						for(i = 0; i < rs_content[4:0]; i = i + 1) begin
							temp = {temp[31],temp[31:1]};
						end

					ALU_result = temp;
					end
					
				6'h02 : //srl
					ALU_result = (rt_content >> shamt);
				
				6'h06 : //srlv
					ALU_result = (rt_content >> rs_content[4:0]);
			
				6'h00 : //sll
					ALU_result = (rt_content << shamt);
				
				6'h04 : //sllv	
					ALU_result = (rt_content << rs_content[4:0]);
				6'b101010: //slt
					begin
						if($signed(rs_content) < $signed(rt_content)) begin
							ALU_result = 1;
						end 
                        else begin
							ALU_result = 0;
						end
					end
				6'h2b : //sltu
					begin
						if($unsigned(rs_content) < $unsigned(rt_content)) begin
							ALU_result = 1;
						end 
                        else begin
							ALU_result = 0;
						end
					end
						
			endcase //case
			
		end // if		
		
		// I type instructions
		else begin
			
			signExtend = {{16{immediate[15]}}, immediate};
			zeroExtend = {{16{1'b0}}, immediate};
			
			case(opcode)
					
				6'h9 : // addiu
					ALU_result = rs_content + signExtend;
					
				6'b001100 : // andi
					ALU_result = rs_content & zeroExtend;

				6'h4 : // beq
					begin
						ALU_result = rs_content - rt_content;
						if(ALU_result == 0) begin
							sig_branch = 1'b1;
						end
						else begin
							sig_branch = 1'b0;
						end
					end
				
				6'h5 : // bne
					begin
						ALU_result = rs_content - rt_content;
						if(ALU_result != 0) begin
							sig_branch = 1'b1;
							ALU_result = 1'b0;
						end
						else begin
							sig_branch = 1'b0;
						end
					end
				
				6'h1 : //bgez (rt = 0), bltz (rs =0), BLTZAL, BGEZAL
					begin
						//$monitor("BGEZAL:", rt_index);
						if(rt_index == 6'h0) begin //bltz
							link = 1'b0;
							if($signed(rs_content) < 0) begin
								sig_branch = 1'b1;
							end 
							else begin 
								sig_branch = 1'b0;
							end
						end 
						else if(rt_index == 6'h1) begin //bgez
							link = 1'b0;
							if($signed(rs_content) >= 0) begin
								sig_branch = 1'b1;
							end 
							else begin 
								sig_branch = 1'b0;
							end
						end 
						else if(rt_index == 5'b10000) begin //bltzal
							//$monitor(rs_content);
								if($signed(rs_content) < 0) begin
								sig_branch = 1'b1;
								link = 1'b1;
							end 
								else begin 
									sig_branch = 1'b0;
									link = 1'b0;
							end
						end
						else if(rt_index == 5'b10001) begin //bgezal
							 if($signed(rs_content) >= 0) begin
								sig_branch = 1'b1;
								link = 1'b1;
								
							end 
							else begin 
								sig_branch = 1'b0;
								link = 1'b0;
							end
						end  	
					end 

				6'h7 : //bgtz
					begin 
						link = 1'b0;
						if($signed(rs_content) > 0) begin
							sig_branch = 1'b1;
						end 
						else begin
							sig_branch = 1'b0;
						end 
					end 
				
				6'h6 : //blez
				 	begin 
				 		link = 1'b0;
						if($signed(rs_content) <= 0) begin
							sig_branch = 1'b1;
						end 
						else begin
							sig_branch = 1'b0;
						end 
					end 
	
				6'b001111 : // lui
					ALU_result = {immediate, {16{1'b0}}};
				
				6'b001101 : // ori
					ALU_result = rs_content | zeroExtend;

				6'b001110 : // xori
					ALU_result = rs_content ^ zeroExtend;
				
				6'b001010 : // slti
					begin
						if($signed(rs_content) < $signed(signExtend)) begin
							ALU_result = 1;
						end else begin
							ALU_result = 0;
						end
					end
				
				6'b001011 : // sltiu
					begin
						if(rs_content < signExtend) begin
							ALU_result = 1;
						end else begin
							ALU_result = 0;
						end
					end
				
			endcase
		
		end
		
	end
	
	
	initial begin
		
	end
	
endmodule
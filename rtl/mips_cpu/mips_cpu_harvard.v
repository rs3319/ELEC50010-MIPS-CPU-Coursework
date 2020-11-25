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

module register(
    
    input logic clk,
    input logic reset,
    
    input logic[2:0] read_index_a,
    output logic[31:0] read_data_a,
    
    input logic[2:0] write_index,
    input logic write_enable,
    input logic[31:0] write_data
);

    logic[31:0] regs[31:0];
    
    logic[31:0] reg_0, reg_1, reg_2, reg_3, reg_4, reg_5, reg_6, reg_7, reg_8, reg_9, reg_10, reg_11, reg_12, reg_13, reg_14, reg_15, reg_16, reg_17, reg_18, reg_19, reg_20, reg_21, reg_22, reg_23, reg_24, reg_25, reg_26, reg_27, reg_28, reg_29, reg_30, reg_31;
    
    assign reg_0 = regs[0];
    assign reg_1 = regs[1];
    assign reg_2 = regs[2];
    assign reg_3 = regs[3];
    assign reg_4 = regs[4];
    assign reg_5 = regs[5];
    assign reg_6 = regs[6];
    assign reg_7 = regs[7];
    assign reg_8 = regs[8];
    assign reg_9 = regs[9];
    assign reg_10 = regs[10];
    assign reg_11 = regs[11];
    assign reg_12 = regs[12];
    assign reg_13 = regs[13];
    assign reg_14 = regs[14];
    assign reg_15 = regs[15];
    assign reg_16 = regs[16];
    assign reg_17 = regs[17];
    assign reg_18 = regs[18];
    assign reg_19 = regs[19];
    assign reg_20 = regs[20];
    assign reg_21 = regs[21];
    assign reg_22 = regs[22];
    assign reg_23 = regs[23];
    assign reg_24 = regs[24];
    assign reg_25 = regs[25];
    assign reg_26 = regs[26];
    assign reg_27 = regs[27];
    assign reg_28 = regs[28];
    assign reg_29 = regs[29];
    assign reg_30 = regs[30];
    assign reg_31 = regs[31];
    
    assign read_data_a = reset==1 ? 0 : regs[read_index_a];
    
    integer index;
    always @(posedge clk) begin
        if (reset==1) begin
            for (index = 0; index < 32; index = index + 1) begin
                regs[index] <= 0;
            end
        end
        else if (write_enable == 1) begin
            regs[write_index] <= write_data;
        end
    end
    
    

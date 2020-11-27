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

module mips_cpu_hilo(

    input logic clk,
    input logic reset,

    input logic[4:0] read_index_rs,
    output logic[31:0] read_data_rs,
    input logic[4:0] read_index_rt,
    output logic[31:0] read_data_rt,
    
    input logic[7:0] write_index,
    input logic write_enable,
    input logic[31:0] write_data_lo,
    input logic[31:0] write_data_hi,
    output logic[31:0] lo_reg,
    output logic[31:0] hi_reg
);
    logic[63:0] prodreg;
    logic[31:0] lo;
    logic[31:0] hi;

    
// remove register signals and only include hi/lo reg and multiplicand multiplier
endmodule
module mips_cpu_hilo(

    input logic[5:0] hilo_control,
    input logic[5:0] opcode,
    input logic clk,
    input logic reset,
    input logic[31:0] a,
    input logic[31:0] b,
    
    
    output logic[31:0] lo_reg,
    output logic[31:0] hi_reg
);
    logic[31:0] temp;
    logic[63:0] toadd;
    logic[63:0] prodreg;
    logic[31:0] lo;
    logic[31:0] hi;
    integer i;

    
// remove register signals and only include hi/lo reg and multiplicand multiplier

always @(posedge clk) begin
    for(i = 0; i < 32; i = i + 1) begin
        temp = a * b[i];
        toadd = temp<<i;
        if(i == 0) begin
            prodreg = toadd;
        end
        else begin
            prodreg = prodreg + toadd;
        end
    end
    hi[31:0] = prodreg[63:32];
    lo[31:0] = prodreg[31:0];
    
    hi_reg = hi;
    lo_reg = lo;
end
endmodule

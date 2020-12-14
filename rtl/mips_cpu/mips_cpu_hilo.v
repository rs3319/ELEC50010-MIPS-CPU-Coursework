module mips_cpu_hilo(

    input logic[5:0] opcode,
    input logic clk,
    input logic reset,
    input logic[31:0] a,
    input logic[31:0] b,
    input logic valid_in,

    output logic valid_out,
    output logic[31:0] lo_reg,
    output logic[31:0] hi_reg
);
    logic[31:0] temp;
    logic[63:0] toadd;
    logic[63:0] prodreg;
    logic[31:0] lo;
    logic[31:0] hi;
    integer i;
	integer divCount;
	logic [31:0] dd;
	logic [63:0] ds;
	logic [63:0] prevR;
	logic [31:0] q;
	logic [63:0] r;
	logic RestoreDivisor;
    
// remove register signals and only include hi/lo reg and multiplicand multiplier

//mfhi, mflo in harvard cpu file
always @(posedge clk) begin
	//$monitor("op: ",opcode);

    case(opcode)
    6'b010001: 
        begin //mthi
            hi <= a;
            hi_reg <= hi;
        end
    
    6'b010011:
        begin //mtlo
            lo <= a;
            lo_reg <= lo;
        end
    
    6'b011001:
        begin //multu
            prodreg <= $unsigned(a) * $unsigned(b);
            hi[31:0] <= prodreg[63:32];
            lo[31:0] <= prodreg[31:0];
        
            hi_reg <= hi;
            lo_reg <= lo;
        end
    
    6'b011000:
        begin //mult
            for(i = 0; i < 32; i = i + 1) begin
                temp <= a * b[i];
                toadd <= temp<<i;
                if(i == 0) begin
                    prodreg <= toadd;
                end
                else begin
                    prodreg <= prodreg + toadd;
                end
            end
            hi[31:0] = prodreg[63:32];
            lo[31:0] = prodreg[31:0];
        
            hi_reg = hi;
            lo_reg = lo;
        end
    
    6'b011010: //need multi-cycle iterative 
        begin //div
	    if(valid_in) begin
	    	$monitor("Begin %10d, %10d",a,b);
			dd <= a;
			ds <= b << 33;
			RestoreDivisor <= 0;
			q <= 0;
			divCount <= 33;
			valid_out <= 0;
			r <= a;
			prevR<= a;
		end
		else if(divCount >= 0) begin
			//$monitor("Iteration: %10d, quotient: %16h, remainder: %8h, ds: %14h",divCount,q,r,ds);

			if(($signed(r - ds) >= 0)&&(divCount != 33)) begin
				q <= {q,1'b1};
				r <= r - ds;
			end
			else begin
				q <= {q,1'b0};
			end

			ds <= ds >> 1;
			if(divCount <= 0) begin
				valid_out <= 1;
				$monitor("remainder: %64h quotient: %32h",r,q);
			end
			else begin
				valid_out <= 0;
			end
			divCount <= divCount - 1;

		end
        end
    
    6'b011011:
        begin //divu
            lo = a/b;
            hi = a%b;
            
            hi_reg = hi;
            lo_reg = lo;
        end
    endcase
end

endmodule

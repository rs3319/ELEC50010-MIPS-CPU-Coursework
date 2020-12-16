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
    assign hi_reg = hi;
    assign lo_reg = lo;
    integer i;
    //Divu
	integer divCount;
	logic [31:0] dd;
	logic [63:0] ds;
    logic [93:0] ds_u;
	logic [63:0] prevR;
	logic [31:0] q;
	logic [63:0] r;
    logic [93:0] r_u;
	logic RestoreDivisor;
    logic div_finish;
    //Div
    logic negFlag;
    logic negDividend;
// remove register signals and only include hi/lo reg and multiplicand multiplier

//mfhi, mflo in harvard cpu file
always @(posedge clk) begin
	//$monitor("lo: ",lo);

    case(opcode)
    6'b010001: 
        begin //mthi
            hi <= a;
        end
    
    6'b010011:
        begin //mtlo
            lo <= a;

        end
    
    6'b011001:
        begin //multu
            prodreg <= $unsigned(a) * $unsigned(b);
            hi[31:0] <= prodreg[63:32];
            lo[31:0] <= prodreg[31:0];
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
            hi[31:0] <= prodreg[63:32];
            lo[31:0] <= prodreg[31:0];
        end
    
    6'b011011: //need multi-cycle iterative 
        begin //divu
	    if(valid_in) begin
	    	//$monitor("Begin %10d, %10d",a,b);
			dd <= a;
			ds_u <= b << 33;
			RestoreDivisor <= 0;
			q <= 0;
			divCount <= 33;
			valid_out <= 0;
			r_u <= a;
			prevR<= a;
		end
		else if(divCount >= 0) begin
			//$monitor("Iteration: %10d, quotient: %16h, remainder: %8h, ds: %14h",divCount,q,r_u,ds_u);

			if(($signed(r_u - ds_u) >= 0)&&(divCount != 33)) begin
				q <= {q,1'b1};
				r_u <= r_u - ds_u;
			end
			else begin
				q <= {q,1'b0};
			end

			ds_u <= ds_u >> 1;
			if(divCount <= 0) begin
				valid_out <= 1;
				//$monitor("remainder: %64h quotient: %32h",r_u,q);
                div_finish <= 1;
			end
			else begin
				valid_out <= 0;
			end
			divCount <= divCount - 1;

		end
        else if(div_finish) begin
                lo <= q;
                hi <= r_u[31:0];
                valid_out <= 1;
        end
        end
    
    6'b011010:
        begin //div
        if(valid_in) begin
            //$monitor("Begin %10d, %10d",a,b);
            if($signed(a) < 0 && $signed(b) < 0) begin //both zero, negflag = 0, take twos complement of both
                dd <= ~a + 1;
                ds <= (~b +1) << 33;
                r <= 64'h0000FFFF&(~a+1);
                prevR<= (~a+1);
                negFlag <= 0;
                negDividend <= 1;
            end
            else if($signed(a) < 0) begin
                dd <= ~a + 1;
                ds <= b << 33;
                r <= (~a+1);
                prevR<= (~a+1);
                negFlag <= 1;
                negDividend <= 1;
            end
            else if($signed(b) < 0) begin
                negFlag <= 1;
                dd <= a;
                ds <= (~b +1) << 33;
                r <= a;
                prevR<= a;
                negDividend <= 0;
            end
            else begin
                negFlag <= 0;
                dd <= a;
                ds <= b << 33;
                r <= a;
                prevR<= a;
                negDividend <= 0;
            end
            RestoreDivisor <= 0;
            valid_out <= 0;
            div_finish <= 0;
            divCount <= 33;
            q <= 0;
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

                //$monitor("remainder: %64h quotient: %32h, Negative? : %1b, NegativeDividend?: %1b, Hi: %10h, Lo : %10h",r[31:0],q,negFlag,negDividend, hi, lo);
                div_finish <= 1;
                valid_out <= 1;
            end

            
            else begin

                valid_out <= 0;
            end
            divCount <= divCount - 1;

        end
        else if(div_finish) begin
                if(negDividend) begin
                    if(a[31] == r[31]) begin
                        hi <= r[31:0];
                    end
                    else begin
                        hi <= ~r[31:0]+1;
                    end
                end
                else begin 
                    //$monitor("Hi Assigned to ", r[31:0]);
                    hi <= r[31:0];

                end
                if(negFlag) begin
                    lo <= ~q+1;
                end
                else begin;
                    lo <= q;
                end
                valid_out <= 1;
            end
        end
    endcase
end

endmodule

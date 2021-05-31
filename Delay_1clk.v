module Delay_1clk #(parameter N = 16)(clk, rst, start, xn, xn_1);

input clk, rst, start;
input [N-1:0]xn;
output reg[N-1:0]xn_1;

always@(posedge clk)
begin

if(rst)
   xn_1 <= 0;

else 
begin
            if(start)
               xn_1 <= xn;

            else
               xn_1 <= 0;
end
end
endmodule
// shifter module 
module shifter #(parameter N = 16)(dataout,datain,shift);

output [N-1:0] dataout;
input [N-1:0] datain;
input [3:0] shift;

	assign dataout = datain >> shift;

endmodule



// 2*1 mux module for control input
module mux21 #(parameter N = 16)(out,a,b,sel);

output  reg [N-1:0]out;
input [N-1:0]a,b;
input sel;

always @ (sel or a or b)
        case (sel)
                1'b0:  out <= a;
                1'b1:  out <= b;
                default: out <= b; 
        endcase 
endmodule 




// parallel cordic main module with pipelining
module cordic_pipeline #(parameter N = 16) (clk,init_angle,sine,cosine,end_angle);

input clk;
input [N-1:0]init_angle;
output [N-1:0]sine,cosine;
output [N-1:0]end_angle;


localparam x0 = 16'b0100000000000000;
localparam y0 = 16'b0;

//arc tan values 
wire [N-1:0]atan[0:N-1];
   
	assign atan[0] = 16'h3243;
  	assign atan[1] = 16'h1dac;
        assign atan[2] = 16'h0fad;
        assign atan[3] = 16'h07f5;
        assign atan[4] = 16'h03fe;
        assign atan[5] = 16'h01ff;
        assign atan[6] = 16'h00ff;
        assign atan[7] = 16'h007f;
        assign atan[8] = 16'h003f;
        assign atan[9] = 16'h001f;
        assign atan[10] = 16'h0010;
        assign atan[11] = 16'h0008;
        assign atan[12] = 16'h0004;
        assign atan[13] = 16'h0002;
        assign atan[14] = 16'h0001;
        assign atan[15] = 16'h0000;

//mux outputs
wire [N-1:0]mox[0:N-1];
wire [N-1:0]moy[0:N-1];
wire [N-1:0]moz[0:N-1];

//delay op
wire [N-1:0]mox_o[0:N-1];
wire [N-1:0]moy_o[0:N-1];
wire [N-1:0]moz_o[0:N-1];

//shift output
wire [N-1:0]sxout[0:N-1];
wire [N-1:0]syout[0:N-1];

//shift delay op
wire [N-1:0]sxout_o[0:N-1];
wire [N-1:0]syout_o[0:N-1];

wire [N-1:0]xn[0:N-1];
wire [N-1:0]yn[0:N-1];
wire [N-1:0]zn[0:N-1];

// first cycle
mux21 mx(.out(mox[0]),.a(x0),.b(y0),.sel(0));
Delay_1clk dl(.clk(clk), .rst(0), .start(1), .xn(mox[0]), .xn_1(mox_o[0]));

mux21 my(.out(moy[0]),.a(y0),.b(y0),.sel(0));
Delay_1clk d2(.clk(clk), .rst(0), .start(1), .xn(moy[0]), .xn_1(moy_o[0]));

shifter sfx(.dataout(sxout[0]),.datain(mox[0]),.shift(4'd1));
Delay_1clk d4(.clk(clk), .rst(0), .start(1), .xn(sxout[0]), .xn_1(sxout_o[0]));

shifter sfy(.dataout(syout[0]),.datain(moy[0]),.shift(4'd1));
Delay_1clk d5(.clk(clk), .rst(0), .start(1), .xn(syout[0]), .xn_1(syout_o[0]));


Add_Sub_Nbit as0(.A(mox[0]),.B(syout[0]),.s(1),.Y(xn[0]));
Add_Sub_Nbit ask(.A(moy[0]),.B(sxout[0]),.s(0),.Y(yn[0]));

//angle operation
mux21 mz(.out(moz[0]),.a(init_angle),.b(y0),.sel(0));
Delay_1clk d3(.clk(clk), .rst(0), .start(1), .xn(moz[0]), .xn_1(moz_o[0]));

Add_Sub_Nbit as5(.A(moz_o[0]),.B(atan[0]),.s(1),.Y(zn[0]));

//angle instantation
genvar j;
generate 

for (j = 0; j<N; j = j+1)begin: z_loop

     mux21 mz(.out(moz[j+1]),.a(0),.b(zn[j]),.sel(1));
     Delay_1clk d3(.clk(clk), .rst(0), .start(1), .xn(moz[j+1]), .xn_1(moz_o[j+1]));

     Add_Sub_Nbit as9(.A(moz_o[j+1]),.B(atan[j+1]),.s(1),.Y(zn[j+1]));

end
endgenerate



genvar i;
generate 

for (i = 0; i<N; i = i+1)begin: cordic_loop

    mux21 m1(.out(mox[i+1]), .a(0),.b(xn[i]),.sel(1));
    Delay_1clk d6(.clk(clk), .rst(0), .start(1), .xn(mox[i+1]), .xn_1(mox_o[i+1]));
    mux21 m2(.out(moy[i+1]), .a(0),.b(yn[i]),.sel(1));
    Delay_1clk d7(.clk(clk), .rst(0), .start(1), .xn(moy[i+1]), .xn_1(moy_o[i+1]));


    shifter sfx(.dataout(sxout[i+1]),.datain(mox[i+1]),.shift(i+1));
    Delay_1clk d8(.clk(clk), .rst(0), .start(1), .xn(sxout[i+1]), .xn_1(sxout_o[i+1]));
    shifter sfy(.dataout(syout[i+1]),.datain(moy[i+1]),.shift(i+1));
    Delay_1clk d9(.clk(clk), .rst(0), .start(1), .xn(syout[i+1]), .xn_1(syout_o[i+1]));


    Add_Sub_Nbit ad1(.A(mox_o[i+1]),.B(syout_o[i+1]),.s(~zn[i][15]),.Y(xn[i+1]));
    Add_Sub_Nbit ad2(.A(moy_o[i+1]),.B(sxout_o[i+1]),.s(zn[i][15]),.Y(yn[i+1]));

end

endgenerate

assign sine = 0.6037*xn[N-1];
assign cosine = 0.6037*yn[N-1];
assign end_angle = zn[N-1];



endmodule









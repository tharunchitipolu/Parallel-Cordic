module cordic_tb();

reg clk;
reg [15:0]init_angle;
wire [15:0]sine,cosine,end_angle;


cordic_pipeline #(16) uut(.clk(clk),.init_angle(init_angle),.sine(sine),.cosine(cosine),.end_angle(endangle));

initial 
begin
 clk = 1;
end

always 
begin
#5 clk = ~clk;
end 
// iteration to compute Sin and Cos from 0 to 45
initial
begin
 init_angle[7:0]=0;
         for(init_angle[15:8]=0; init_angle[15:8] <= 45; init_angle[15:8] = init_angle[15:8] + 1)
		   begin
			
			#50 $monitor($time," CosX = %b",cosine," SinX = %b ",sine," angle=+%d",init_angle[15:8]);
				
		   end 

end

endmodule


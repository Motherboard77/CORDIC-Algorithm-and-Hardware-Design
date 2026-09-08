`timescale 1ns / 1ps

module stimulus;
parameter M = 22;
parameter N = 16;
reg signed [N - 1:0] theta_d;
reg clk,rst_n;
wire signed [M - 1:0] cos_theta;
wire signed [M - 1:0] sine_theta;
integer i;
reg valid;
integer outFile;
CORDIC cordicParallel
(
theta_d,
clk,
rst_n,
cos_theta,
sine_theta);
initial
begin
clk = 0;
valid = 0;
outFile = $fopen("monitor.txt","w");
# 300 valid = 1;
# 395 valid = 0;
end
initial
begin
#5
theta_d = -29491;
// For theta_d = -0.9:0.1:0.9
for (i=0; i<20 ; i=i+1)
#20 theta_d = theta_d + 3276;
#400 
$fclose(outFile);
$finish;
end
always
#10 clk = ~clk;
initial
$monitor($time, " theta = %d, cos_theta = %d, sine_theta = %d",
theta_d, cos_theta, sine_theta);
// $monitor(" \t%d \t%d \t%d", theta_d, cos_theta, sine_theta);
always@ (posedge clk)
if(valid)
$fwrite(outFile, " %d %d\n", cos_theta, sine_theta);
endmodule 

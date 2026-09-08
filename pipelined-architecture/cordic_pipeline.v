`timescale 1ns / 1ps

module CORDIC #(parameter M = 22, N = 16, K=22'h0DBD96)
// In Q2.20 format value of K = 0.8588
(
input signed [N - 1:0] theta_d,
input clk,
input rst_n,
output signed [M - 1:0] cos_theta,
output signed [M - 1:0] sine_theta);
reg signed [M-1:0] x_pipeline [0:N-1];
reg signed [M-1:0] y_pipeline [0:N-1];
reg signed [N-1:0] theta_pipeline [0:N-1];
reg signed [M-1:0] x[0:N];
reg signed [M-1:0] y[0:N];
reg signed [N-1:0] theta[0:N];
reg signed [N-1:0] arcTan[0:N-1];
integer i;
// Arctan table: radian values are represented in Q1.15 format
always @*
begin
arcTan[0] = 16'h3B59;
arcTan[1] = 16'h1F5B;
arcTan[2] = 16'h0FEB;
arcTan[3] = 16'h07FD;
arcTan[4] = 16'h0400;
arcTan[5] = 16'h0200;
arcTan[6] = 16'h0100;
arcTan[7] = 16'h0080;
arcTan[8] = 16'h0040;
arcTan[9] = 16'h0020;
arcTan[10] = 16'h0010;
arcTan[11] = 16'h0008;
arcTan[12] = 16'h0004;
arcTan[13] = 16'h0002;
arcTan[14] = 16'h0001;
arcTan[15] = 16'h0000;
end
always @*
begin
x[0] = K;
y[0] = 0;
theta[0] = theta_d;
CE_task(x[0], y[0], theta[0], arcTan[0], 4'd1, x[1],y[1], theta[1]);
for (i=0; i<N-1; i=i+1)
begin
CE_task(x_pipeline[i], y_pipeline[i], theta_pipeline[i],
arcTan[i+1], i+2, x[i+2], y[i+2], theta[i+2]);
end
end
always @(posedge clk)
begin
for(i=0; i<N-1; i=i+1)
begin
x_pipeline[i] <= x[i+1];
y_pipeline[i] <= y[i+1];
theta_pipeline[i] <= theta[i+1];
end
end
assign cos_theta = x_pipeline[N-2];
assign sine_theta =y_pipeline[N-2];
task CE_task(
input signed [M - 1:0] x_i,
input signed [M - 1:0] y_i,
input signed [N - 1:0] theta_i,
input signed [N - 1:0] Delta_theta,
input [3:0]i,
output reg signed [M - 1:0] x_iP1,
output reg signed [M - 1:0] y_iP1,
output reg signed [N - 1:0] theta_iP1);
reg sigma, sigma_bar;
reg signed [M - 1:0] x_input, y_input;
reg signed [M - 1:0] x_shifted, y_shifted, x_bar_shifted,
y_bar_shifted;
reg signed [N - 1:0] Delta_theta_input, Delta_theta_bar;
begin
sigma = theta_i[N-1]; // Sign bit of the angle
sigma_bar = ~sigma;
x_shifted = x_i >>> i; // Shift by 2^-i
y_shifted = y_i >>> i; // Shift by 2^-i
x_bar_shifted = ~x_shifted + 1;
y_bar_shifted = ~y_shifted + 1;
Delta_theta_bar = ~Delta_theta + 1;
if ((sigma)||(theta_i == 0))
begin
x_input = x_bar_shifted; // Subtract if sigma is negative
y_input = y_shifted; // Add if sigma is negative

Delta_theta_input = Delta_theta; // Add if sigma is negative
end
else
begin
x_input = x_shifted;
y_input = y_bar_shifted;
Delta_theta_input = Delta_theta_bar;
end
x_iP1 = x_i + y_input;
y_iP1 = x_input + y_i;
theta_iP1 = theta_i + Delta_theta_input;
end
endtask
endmodule

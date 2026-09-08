`timescale 1ns / 1ps

module d_latch_theta(  
input [24:0] d_theta,
input clk,
input enable,
  output reg [24:0] q_theta);

always@(posedge clk)
    begin
      if(enable)
    	begin    
    		q_theta = d_theta;
        end
    end
endmodule
`timescale 1ns / 1ps

module CORDIC1_test();
  
  reg [15:0] x_in;
  reg [15:0] y_in;
  reg [24:0] theta_in;
  reg clk = 1'b0;
  wire [15:0] cos_theta;
  wire [15:0] sin_theta;
  
  
  reg [24:0] radian_reg[0:35];
  integer f1,i;
 
CORDIC1 WAVE(x_in,y_in,theta_in,clk,cos_theta,sin_theta);
  
  always begin
    #10 clk = ~clk;
  end
  
  initial begin
      x_in = 16'b1011_1101_1001_0110 ; 
      y_in = 16'b0000_0000_0000_0000 ;
      
       
      
      //create a file RO.txt to store the output dats
      f1 = $fopen("theta_val1.txt","w");
      
      //display first line with literals c0s_val_radian sin_val_radian
      $fdisplay(f1,"cos_val_radian","                   ","sin_val_radian");
      
      //read the cos and sin values into the file created
      $fmonitor(f1,"%b                          %b",cos_theta,sin_theta);
           
      $readmemb("radian_logger.txt",radian_reg);
      
      $fmonitor(f1,"%b                          %b",cos_theta,sin_theta);
        for (i=0;i<=35;i=i+1)    //total 35 entries
        begin
       
        #300    theta_in <= radian_reg[i];
           
        end
      
      $fclose(f1);  
  end
 
endmodule



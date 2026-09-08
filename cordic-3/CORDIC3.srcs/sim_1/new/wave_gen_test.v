`timescale 1ns / 1ps

module CORDIC_ELEMENT_test();
  
  parameter M=15, N=24;
  
  reg [M:0] x_in;
  reg [M:0] y_in;
  reg [N:0] theta_in;
  reg clk = 1'b1;
  wire [M:0] cos_theta;
  wire [M:0] sin_theta;
  
  
  reg [24:0] radian_reg[0:35];
  integer f1,i;
 
CORDIC_ELEMENT WAVE(x_in,y_in,theta_in,clk,cos_theta,sin_theta);
  
  always begin
    #20 clk = ~clk;
  end
  
  initial begin
      x_in = 16'b1011_1101_1001_0110 ; 
      y_in = 16'b0000_0000_0000_0000 ;  
      
      //create a file RO.txt to store the output dats
      f1 = $fopen("theta_val.txt","w");
      
      //display first line with literals c0s_val_radian sin_val_radian
      $fdisplay(f1,"cos_val_radian","                   ","sin_val_radian");
      
      //read the cos and sin values into the file created
      $fmonitor(f1,"%b                          %b",cos_theta,sin_theta);
           
      $readmemb("radian_logger.txt",radian_reg);
      
      $fmonitor(f1,"%b                          %b",cos_theta,sin_theta);
      
      //read the values from the theta_vaal.txt file till EOF is reached
      //keep reading files till EOF is found
      for (i=0;i<=35;i=i+1)    //total 35 entries
      begin
       
        #1000 theta_in <= radian_reg[35-i];
      
        //strentch the timeline
        //$display(ALU_Out);
      end
      
      $fclose(f1);  
  end
 
endmodule


`timescale 1ns / 1ps

module CORDIC1(
  input [15:0] x_phasor,    //HAS AN INITIAL VALUE OF K=...
  input [15:0] y_phasor,    //HAS AN INITIAL VALUE OF 0
  input [24:0] theta_in,    //25-bit instruction set
  input slave_clk,          //take the slave_clk as 100 KHz
  output reg [15:0] cos_val,
  output reg [15:0] sin_val);
    
  reg [24:0] arcTan[0:15];  
//  reg [15:0] first_quad_x_computed[9:0] ; //16-bit radian value of x(COS)
//  reg [15:0] first_quad_y_computed[9:0] ; //16-bit radian vlaue of y(SIN)
  
  reg signed [15:0] x;  	  //to store the previous iteraiton x value
  reg signed [15:0] y;  	  //to store the previous iteraiton y value
  reg signed [24:0] theta; //to store the previous iteraiton theta value
  
  integer sigma;                  //decides the sign (1,-1)
  integer write_pointer,j;
    
  initial begin
    sigma <= 1;
    x = x_phasor;
    y = y_phasor;
    j   = 0;
    cos_val <= x_phasor;
    sin_val <= y_phasor;
    end
  
  always @(*)
    begin
      //store the arcTan values here , for 16 iterations
      arcTan[0] = 25'b0000011001001000011111101;   //45 deg = taninverse(2^-0) 
      arcTan[1] = 25'b0000001110110101100011001;   //taninverse(2^-1)
      arcTan[2] = 25'b0000000111110101101101010;
      arcTan[3] = 25'b0000000011111110101011011;
      arcTan[4] = 25'b0000000001111111110100101;
      arcTan[5] = 25'b0000000000111111111100101;
      arcTan[6] = 25'b0000000000011111111111011;
      arcTan[7] = 25'b0000000000001111111110101;
      arcTan[8] = 25'b0000000000001000000000011;
      arcTan[9] = 25'b0000000000000100000000010;
      arcTan[10]= 25'b0000000000000010000000001;
      arcTan[11]= 25'b0000000000000000111111111;
      arcTan[12]= 25'b0000000000000000100000000;
      arcTan[13]= 25'b0000000000000000001111110;
      arcTan[14]= 25'b0000000000000000001000000;
      arcTan[15]= 25'b0000000000000000000100101;
    end


  
  always @(posedge slave_clk)
    begin  
    
      
          case(theta_in[24:23])
          
          2'b00:  //first quadrant
         	  begin
              		if(j == 0)   //compute initial x,y and theta value
                	begin
                  	 theta= theta_in;
                  	 x = x- sigma*(y>>j);
                  	 y= y + sigma*(x>>j);
                  	 theta= theta - sigma*(arcTan[j]);
                  	 j= j + 1;
                  	 cos_val <= x;
                     sin_val <= y;
                  	 
                  	end
              		else 
                	begin
                  		if(theta < 0 || j<15) 
                    	begin
                      	sigma = -1;
                      	
                      	x = x- sigma*(y>>j);
                      	y = y+ sigma*(x>>j);
                      	theta = theta - sigma*(arcTan[j]);
                      	j = j + 1;
                      	cos_val <= x;
                        sin_val <= y;
                  	  	
                      	end
                  
                  		else if(theta > 0 || j<15)
                    	begin
                      	sigma = 1;
                      	x = x - sigma*(y>>j);
                      	y = y + sigma*(x>>j);
                      	theta = theta - sigma*(arcTan[j]);
                      	j = j + 1;
                        cos_val <= x;
                        sin_val <= y;           	
                      	end
                      	
                      	else if (j == 15)
                      	begin
                      	cos_val <= x;
                        sin_val <= y;
                        j <= 0;
                      	end
                      	
                    end
                 
              end                                          
         
          default: 
                    begin
                      cos_val <= cos_val;
                      sin_val <= sin_val;
                      j <= j;
                    end
          endcase
        
      end

endmodule
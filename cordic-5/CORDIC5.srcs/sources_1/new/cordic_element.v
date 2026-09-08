module cordic_element(
  input [24:0] theta_in,
  input clock,
  output reg [23:0] cos_val,
  output reg [23:0] sin_val
   );
  
  reg [23:0] x[1:0];
  reg [23:0] y[1:0];
  reg signed [24:0] theta[1:0];
  reg signed [24:0] arcTan[15:0];
  integer i, sigma;
 
  initial 
    begin
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
      x[0] 	   <= 24'b0000_1101_1011_1101_1001_0110 ;
      y[0] 	   <= 24'b0000_0000_0000_0000_0000_0000 ;
      //theta[0] <= theta_in;
      i <=0;
      sigma <=1;
    end
  
  
  always @(posedge clock) begin

    if(i == 0) 
      			begin
                  x[1] = x[0] - (sigma)*(y[0]>>i);
                  y[1] = y[0] + (sigma)*(x[0]>>i);
                  theta[0] = theta_in - (sigma)*(arcTan[i]);
                  //theta_realtime = theta[0];
                  x[0] = x[1];
                  y[0] = y[1];
                  //theta[0] = theta[1];
                  i = i + 1;
                  //theta_realtime <= theta[0];
                  end
    
    else if(theta[0] < 0 && i>0 && i<15)
      
      			begin
                  	sigma = -1;
                    x[1] = x[0] - (sigma)*(y[0]>>i);
                  	y[1] = y[0] + (sigma)*(x[0]>>i);
                  	theta[1] = theta[0] - (sigma)*(arcTan[i]);
                  	x[0] = x[1];
                  	y[0] = y[1];
                  	theta[0] = theta[1];
                  	i = i + 1;
                  	//cos_val <= x[0];
                  //sin_val <= y[0];
                end
    
    else if(theta[0] > 0 && i>0 && i<15)
      
      			begin
                  	sigma = 1;
                    x[1] = x[0] - (sigma)*(y[0]>>i);
                  	y[1] = y[0] + (sigma)*(x[0]>>i);
                  	theta[1] = theta[0] - (sigma)*(arcTan[i]);
                  	x[0] = x[1];
                  	y[0] = y[1];
                  	theta[0] = theta[1];
                  	i = i + 1;
                  	//cos_val <= x[0];
                  //sin_val <= y[0];
                end

    else if(i == 15)
      
      			begin
                  cos_val <= x[0];
                  sin_val <= y[0];
                  i = 0;
                end
    end
 
endmodule
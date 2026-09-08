`timescale 1ns / 1ps

  
  module CORDIC_ELEMENT(
  input [15:0] x_phasor,    //HAS AN INITIAL VALUE OF K=...
  input [15:0] y_phasor,    //HAS AN INITIAL VALUE OF 0
  input [24:0] theta_in,    //25-bit instruction set
  input slave_clk,          //take the slave_clk as 100 KHz
  output reg [15:0] cos_val,
  output reg [15:0] sin_val);
  
  reg [24:0] arcTan[0:15];  //tan inverse lut
  reg [15:0] first_quad_x_computed[9:0] ; //16-bit radian value of x(COS)
  //note that it can store only 10 amplitute levels
  reg [15:0] first_quad_y_computed[9:0] ; //16-bit radian vlaue of y(SIN)
  
  reg [15:0] x_computation_temp[1:0];  	  //to store the previous iteraiton x value
  reg [15:0] y_computation_temp[1:0];  	  //to store the previous iteraiton y value
  reg [24:0] theta_computation_temp[1:0]; //to store the previous iteraiton theta value
  
  integer sigma;                  //decides the sign (1,-1)
  integer write_pointer,read_pointer,j;
  
  reg EN; //EN IS enbled depending on the COUNT value . COUNT in turn depends on the clock
  reg [4:0] count; //counter value increments wrt clk 
  
  wire master_clk; //output from cock divider module
  
  wire [24:0] latched_theta_input;
  reg [15:0] x_phasor_in;
  reg [15:0] y_phasor_in;
  
  initial begin
    x_phasor_in = x_phasor;
    y_phasor_in = y_phasor;
    sigma = 1;
    x_computation_temp[0] = x_phasor_in;
    y_computation_temp[0] = y_phasor_in;
    count = 4'b0000;
    write_pointer = 0;
    read_pointer = 0;
    j=0;
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
  
  clock_divider(slave_clk,master_clk); //divide the slave clock to accomodate its 16 
  //iterations for every time period
  
  //theta_in format should be in radian with fixed point notation
  //some part of MSB bits are kept reserved for Quadrant check
  //computation is only done for first quadrant, and computed x and 
  //y values are stored in a separate LUT
  //now when the phasor enters the 2nd, 3rd and 4th quadrants, only 
  //inversion operation need to be pperformed depending on quadrant
  //number
  //also, include a D-LATCH in the beginning of the CORDIC ELEMENT, to LATCH the input
  //i.e theta, and perform 16 iterations on it, then LATCH the next theta value
  //Also, when the first quadrant computation is done, control should  shift to a second
  //process, called INVERSION, that perform invesion based on input theta value and 
  //inverting from the (x,y) LUT.
  
 
      //LATCH THE THETA VALUE INSIDE THE CORDIC ELEMENT, DEPENDING ON ENABLE INPUT
      //d_latch_theta(input d_theta,input clk,input enable,output reg q_theta);
  
  d_latch_theta(theta_in,master_clk,EN,latched_theta_input);
 
  
  always @(posedge master_clk)   //the master clock latches the next input theta value
    begin
      if(count == 4'b1111)// || count == 4'b0000)  //16 iterations of theta completed
        begin
          EN = 1'b1;        //LATCH the next theta value
          //count = 4'b0000;
          //count = count + 1;
        end
      else 
        begin
          EN = 1'b0; 
          //count = count + 1;
        end
    end
  
  //perform computation at every positive edge of the slave_clk
  
  always @(slave_clk)
    begin
    //check latched_theta_input's first couple of bits for QUADRANT CHECK
    //make a switch case statement for inversion, value extracted from stored x,y LUT 	  //table
    //encase the switch statement inside the if else of count statement 
    //if(count <= 4'b1111)
    //perform the computation based on Quadrant check, increment count
    
  if(count < 4'b1111) //0 to 14
      begin
        //give switch case of theta
          case(latched_theta_input[24:23])
          
          2'b00:  //first quadrant
         	  begin
              		if(count == 4'b0000)   //compute initial x,y and theta value
                	begin
                  	theta_computation_temp[0] = latched_theta_input;
                  	x_computation_temp[1] = x_computation_temp[0] - sigma*(y_computation_temp[0]>>count);
                  	y_computation_temp[1] = y_computation_temp[0] + sigma*(x_computation_temp[0]>>count);
                  	theta_computation_temp[1] = theta_computation_temp[0] - sigma*(arcTan[count]);
                  	count = count + 1;
                  
                  	//shift the values to upper registers
                  	x_computation_temp[0] 	= x_computation_temp[1];
                  	y_computation_temp[0] 	= y_computation_temp[1];
                  	theta_computation_temp[0] = theta_computation_temp[1];
                	end
              		else 
                	begin
                  		if(theta_computation_temp[0]<0) 
                    	begin
                      	sigma = -1;
                      	x_computation_temp[1] = x_computation_temp[0] - sigma*(y_computation_temp[0]>>count);
                      	y_computation_temp[1] = y_computation_temp[0] + sigma*(x_computation_temp[0]>>count);
                      	theta_computation_temp[1] = theta_computation_temp[0] - sigma*(arcTan[count]);
                      	count = count + 1;
                      
                      	//shift the values to upper registers
                  	  	x_computation_temp[0] 	= x_computation_temp[1];
                      	y_computation_temp[0] 	= y_computation_temp[1];
                      	theta_computation_temp[0] = theta_computation_temp[1];
                		end
                  
                  		else if(theta_computation_temp[0] > 0)
                    	begin
                      	sigma = 1;
                      	x_computation_temp[1] = x_computation_temp[0] - sigma*(y_computation_temp[0]>>count);
                      	y_computation_temp[1] = y_computation_temp[0] + sigma*(x_computation_temp[0]>>count);
                      	theta_computation_temp[1] = theta_computation_temp[0] - sigma*(arcTan[count]);
                      	count = count + 1;
                      
                      	//shift the values to upper registers
                  	  	x_computation_temp[0] 	= x_computation_temp[1];
                      	y_computation_temp[0] 	= y_computation_temp[1];
                      	theta_computation_temp[0] = theta_computation_temp[1];
                    	end
                 	end
              end                                           //end of case 00
          2'b01:  //Second quadrant
            	if(count ==4'b1111)
              	begin
					count = 4'b0000;
                end
                else
                begin
                  cos_val = 	-first_quad_x_computed[write_pointer - count];
                  sin_val =     first_quad_y_computed[write_pointer - count];  
                  count = count + 1;
          		end
            
          2'b10:   //Third quadrant
            		if(count ==4'b1111)
              		begin
						count = 4'b0000;
                	end
                	else
                	begin
                  		cos_val = 	-first_quad_x_computed[count];
                  		sin_val =   -first_quad_y_computed[count];  
                  		count = count + 1;
          		end
          2'b11:   //Fourth quadrant
            		if(count ==4'b1111)
              		begin
						count = 4'b0000;
                	end
                	else
                	begin
                      cos_val = 	first_quad_x_computed[write_pointer - count];
                      sin_val =    -first_quad_y_computed[write_pointer - count];  
                  	  count = count + 1;
          			end
          default: 
                    begin
                      cos_val <= cos_val;
                      sin_val <= sin_val;
                      count <= count;
                    end
          endcase
        
      end
    
            else if (count == 4'b1111 && latched_theta_input[24:23] == 2'b00)    
            //store the computed value on a LUT for the first quadrant
              begin
                first_quad_x_computed[write_pointer] = x_computation_temp[0];
                first_quad_y_computed[write_pointer] = y_computation_temp[0];
                //send it to the output
                cos_val = x_computation_temp[0];
                sin_val = y_computation_temp[0];
                write_pointer = write_pointer + 1;
                count = 4'b0000; 
              end
      
  end   													//end of posedge slave clock
  
  
  
endmodule


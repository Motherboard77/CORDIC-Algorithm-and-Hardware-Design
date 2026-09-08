module cordic_element_test();
  
  reg [24:0] theta_in;
  reg clock = 1'b0;
  wire [23:0] cos_theta;
  wire [23:0] sin_theta;
  
  integer f1;
  
  cordic_element uut(theta_in,clock,cos_theta,sin_theta);
  
  always 
    #10 clock <= ~clock;
  
  initial 
    begin
    
        f1 = $fopen("theta_val.txt","w");
    
//        //display first line with literals c0s_val_radian sin_val_radian
        $fdisplay(f1,"cos_val_radian","                   ","sin_val_radian");
      
//        //read the cos and sin values into the file created
        $fmonitor(f1,"%b                          %b",cos_theta,sin_theta);
    
        theta_in <= 25'b0000000101100101011100011;
        #200
        theta_in <= 25'b0000001011001010111000110;
        #200
        theta_in <= 25'b0000010000110000010101001;
        #200
        theta_in <= 25'b0000010110010101110001100;
        #200
        theta_in <= 25'b0000011011111011001110000;
        #200
        theta_in <= 25'b0000100001100000101010101;
        #200
        theta_in <= 25'b0000100111000110000110101;
        #200
        theta_in <= 25'b0000101100101011100010101;
        #200
        theta_in <= 25'b0000110010010000111111111;
        
        $fclose(f1); 
    end
  
endmodule

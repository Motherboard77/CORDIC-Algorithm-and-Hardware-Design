`timescale 1ns / 1ps

//drive the d_latch using the master_clock
//drive the CORDIC_ELEMENT using the slave_clock
//1 positive level of the master_clock should accompany 8 0->1 transitions of the //slave_clock
//such that for 1 time period of the master_clock, we get 16 clock cycles(16 iteraitons)
//from the slave_clock, driving the CORDIC_ELEMENT

module clock_divider(
input s_clock,         
output reg m_clock
);

  reg [4:0] count;
  
  always @(posedge s_clock)
    begin
      if(count == 5'b00000)
        begin
          m_clock = 1'b1;
        end
      else if(count == 5'b01000)  //8 samples 
        begin
          m_clock = ~m_clock;
        end
      else if(count == 5'b10000)  //16 samples
        begin
          m_clock = ~m_clock;
          count = 5'b00000;
        end
      else 
        begin
          count = count + 1;
        end
    end
endmodule

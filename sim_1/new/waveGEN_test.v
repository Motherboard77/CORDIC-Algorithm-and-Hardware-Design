`timescale 1 ns/100 ps

module cordic_test;

reg  [15:0] Xin, Yin;
reg  [31:0] angle;
wire [16:0] Xout, Yout;
reg         CLK_100MHZ;
//
// Waveform generator
//
localparam FALSE = 1'b0;
localparam TRUE = 1'b1;

localparam VALUE = 32000/1.647; // reduce by a factor of 1.647 since thats the gain of the system

reg signed [63:0] i;
reg      start;

initial
begin
   start = FALSE;
   $write("Starting sim");
   CLK_100MHZ = 1'b0;
   angle = 0;
   Xin = VALUE;                     // Xout = 32000*cos(angle)
   Yin = 1'd0;
	i=60;
	// Yout = 32000*sin(angle)

   #10;
   @(posedge CLK_100MHZ);
   start = TRUE;

   // sin/cos output
   for (i = 0; i < 360; i = i + 1)     // from 0 to 359 degrees in 1 degree increments
//   for (i = 30; i < 60; i = i + 30)     // increment by 30 degrees only
   begin
      @(posedge CLK_100MHZ);
      start = FALSE;
      angle = ((1 << 32)*i)/360;    // example: 45 deg = 45/360 * 2^32 = 32'b00100000000000000000000000000000 = 45.000 degrees -> atan(2^0)
      end
end

 sine_cosine uut(CLK_100MHZ, angle, Xin, Yin, Xout, Yout);



initial
begin
  CLK_100MHZ = 1'b0;
  #5;
  forever
  begin
    #5 CLK_100MHZ = 1'b1;
    #5 CLK_100MHZ = 1'b0;
  end
end

endmodule
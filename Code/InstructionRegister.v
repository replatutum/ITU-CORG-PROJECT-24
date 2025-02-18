// EMRE YAMAC 150210077
// ALPER TUTUM 150210088
`timescale 1ns/1ps


module InstructionRegister(
  input wire[7:0] I,
  input wire Write,
  input wire LH,
  
  input wire Clock,

  output reg[15:0] IROut
);

always @(posedge Clock) begin
  if(Write) begin
   if (!LH) begin  //Load LSB
     IROut[7:0] <= I;
   end
   else begin  //Load MSB
     IROut[15:8] <= I;
   end
 end
end
endmodule
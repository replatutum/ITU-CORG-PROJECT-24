// EMRE YAMAC 150210077
// ALPER TUTUM 150210088
`timescale 1ns/1ps

`include "Register.v"

module AddressRegisterFile (
  input wire[15:0] I,

  input wire[1:0] OutCSel,
  input wire[1:0] OutDSel,

  input wire[2:0] FunSel,
  input wire[2:0] RegSel,

  input wire Clock,

  output reg[15:0] OutC,
  output reg[15:0] OutD
);

wire PCE;
wire ARE;
wire SPE;

reg PCR;
reg ARR;
reg SPR;

assign PCE = PCR;
assign ARE = ARR;
assign SPE = SPR;

Register AR(.I(I), .E(ARE), .FunSel(FunSel), .Clock(Clock));
Register PC(.I(I), .E(PCE), .FunSel(FunSel), .Clock(Clock));
Register SP(.I(I), .E(SPE), .FunSel(FunSel), .Clock(Clock));

always @(*) begin
  ARR = 1'b0;
  PCR = 1'b0;
  SPR = 1'b0;

  case (RegSel)
    3'b000:begin
      PCR <= 1'b1;
      ARR <= 1'b1;
      SPR <= 1'b1;
    end
    3'b001:begin
      PCR <= 1'b1;
      ARR <= 1'b1;
    end
    3'b010:begin
      PCR <= 1'b1;
      SPR <= 1'b1;
    end
    3'b011:begin
      PCR <= 1'b1;
    end
    3'b100:begin
      ARR <= 1'b1;
      SPR <= 1'b1;
    end
    3'b101:begin
      ARR <= 1'b1;
    end
    3'b110:begin
      SPR <= 1'b1;
    end
    //no case for 3'b111 because initially all registers are disabled
  endcase

  case (OutCSel)
    2'b00:  OutC <= PC.Q;
    2'b01:  OutC <= PC.Q;
    2'b10:  OutC <= AR.Q;
    2'b11:  OutC <= SP.Q;
  endcase
  case (OutDSel)
    2'b00:  OutD <= PC.Q;
    2'b01:  OutD <= PC.Q;
    2'b10:  OutD <= AR.Q;
    2'b11:  OutD <= SP.Q;
  endcase
end

endmodule
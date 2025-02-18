// EMRE YAMAC 150210077
// ALPER TUTUM 150210088

`timescale 1ns/1ps

module ArithmeticLogicUnitSystem(
  input wire[2:0] RF_OutASel,
  input wire[2:0] RF_OutBSel,
  input wire[2:0] RF_FunSel,
  input wire[3:0] RF_RegSel,
  input wire[3:0] RF_ScrSel,

  input wire[4:0] ALU_FunSel,
  input wire ALU_WF,

  input wire[1:0] ARF_OutCSel,
  input wire[1:0] ARF_OutDSel,
  input wire[2:0] ARF_FunSel,
  input wire[2:0] ARF_RegSel,

  input wire IR_LH,
  input wire IR_Write,

  input wire Mem_WR,
  input wire Mem_CS,

  input wire[1:0] MuxASel,
  input wire[1:0] MuxBSel,
  input wire MuxCSel,

  input wire Clock

);

wire[15:0] OutA;
wire[15:0] OutB;

wire[15:0] ALUOut;

wire[15:0] OutC;

wire[15:0] Address;
wire[7:0] MemOut;

wire[15:0] MuxAOut;
wire[15:0] MuxBOut;
wire[7:0] MuxCOut;

wire[15:0] IROut;

reg[15:0] MuxAReg;
reg[15:0] MuxBReg;
reg[7:0] MuxCReg;

assign MuxAOut = MuxAReg;
assign MuxBOut = MuxBReg;
assign MuxCOut = MuxCReg;

RegisterFile RF(.I(MuxAOut), .OutASel(RF_OutASel), .OutBSel(RF_OutBSel),
                .FunSel(RF_FunSel), .RegSel(RF_RegSel), .ScrSel(RF_ScrSel),
                .Clock(Clock), .OutA(OutA), .OutB(OutB));

ArithmeticLogicUnit ALU(.A(OutA), .B(OutB), .FunSel(ALU_FunSel), .WF(ALU_WF),
                        .Clock(Clock), .ALUOut(ALUOut));

AddressRegisterFile ARF(.I(MuxBOut), .OutCSel(ARF_OutCSel), .OutDSel(ARF_OutDSel),
                        .FunSel(ARF_FunSel), .RegSel(ARF_RegSel), .Clock(Clock),
                        .OutC(OutC), .OutD(Address));

Memory MEM(.Address(Address), .Data(MuxCOut), .WR(Mem_WR), .CS(Mem_CS), .Clock(Clock),
          .MemOut(MemOut));

InstructionRegister IR(.I(MemOut), .Write(IR_Write), .LH(IR_LH), .Clock(Clock),
                      .IROut(IROut));

always @(*) begin
  case (MuxASel)
    2'b00: MuxAReg = ALUOut;
    2'b01: MuxAReg = OutC;
    2'b10: MuxAReg = MemOut;
    2'b11: MuxAReg = IROut[7:0];
  endcase

  case (MuxBSel)
    2'b00: MuxBReg = ALUOut;
    2'b01: MuxBReg = OutC;
    2'b10: MuxBReg = MemOut;
    2'b11: MuxBReg = IROut[7:0];
  endcase

  case (MuxCSel)
    1'b0: MuxCReg = ALUOut[7:0];
    1'b1: MuxCReg = ALUOut[15:8];
  endcase
end

endmodule
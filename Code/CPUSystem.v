// EMRE YAMAC 150210077
// ALPER TUTUM 150210088

`timescale 1ns/1ps

module CPUSystem(
  input wire Clock,
  input wire Reset,

  output reg[7:0] T
);

// Sequence counter is defined in the CPU since it was not included in ALU
reg[2:0] SC;

// M is a flip flop for checking if the instruction is memory reference
reg M;

// CLR is a flip flop for clearing SC
reg CLR;

// Output of IR
wire[15:0] IR;

// Instantiation of the ArithmeticLogicUnitSystem module here
reg[2:0] RF_OutASelReg;
reg[2:0] RF_OutBSelReg;
reg[2:0] RF_FunSelReg;
reg[3:0] RF_RegSelReg;
reg[3:0] RF_ScrSelReg;
reg[4:0] ALU_FunSelReg;
reg ALU_WFReg;
reg[1:0] ARF_OutCSelReg;
reg[1:0] ARF_OutDSelReg;
reg[2:0] ARF_FunSelReg;
reg[2:0] ARF_RegSelReg;
reg IR_LHReg;
reg IR_WriteReg;
reg Mem_WRReg;
reg Mem_CSReg;
reg[1:0] MuxASelReg;
reg[1:0] MuxBSelReg;
reg MuxCSelReg;

wire[2:0] RF_OutASel;
wire[2:0] RF_OutBSel;
wire[2:0] RF_FunSel;
wire[3:0] RF_RegSel;
wire[3:0] RF_ScrSel;
wire[4:0] ALU_FunSel;
wire ALU_WF;
wire[1:0] ARF_OutCSel;
wire[1:0] ARF_OutDSel;
wire[2:0] ARF_FunSel;
wire[2:0] ARF_RegSel;
wire IR_LH;
wire IR_Write;
wire Mem_WR;
wire Mem_CS;
wire[1:0] MuxASel;
wire[1:0] MuxBSel;
wire MuxCSel;

assign RF_OutASel = RF_OutASelReg;
assign RF_OutBSel = RF_OutBSelReg;
assign RF_FunSel = RF_FunSelReg;
assign RF_RegSel = RF_RegSelReg;
assign RF_ScrSel = RF_ScrSelReg;
assign ALU_FunSel = ALU_FunSelReg;
assign ALU_WF = ALU_WFReg;
assign ARF_OutCSel = ARF_OutCSelReg;
assign ARF_OutDSel = ARF_OutDSelReg;
assign ARF_FunSel = ARF_FunSelReg;
assign ARF_RegSel = ARF_RegSelReg;
assign IR_LH = IR_LHReg;
assign IR_Write = IR_WriteReg;
assign Mem_WR = Mem_WRReg;
assign Mem_CS = Mem_CSReg;
assign MuxASel = MuxASelReg;
assign MuxBSel = MuxBSelReg;
assign MuxCSel = MuxCSelReg;

ArithmeticLogicUnitSystem _ALUSystem(.RF_OutASel(RF_OutASel), .RF_OutBSel(RF_OutBSel), .RF_FunSel(RF_FunSel),
                                    .RF_RegSel(RF_RegSel), .RF_ScrSel(RF_ScrSel),
                                    .ALU_FunSel(ALU_FunSel), .ALU_WF(ALU_WF),
                                    .ARF_OutCSel(ARF_OutCSel), .ARF_OutDSel(ARF_OutDSel), .ARF_FunSel(ARF_FunSel), .ARF_RegSel(ARF_RegSel),
                                    .IR_LH(IR_LH), .IR_Write(IR_Write), .Mem_WR(Mem_WR), .Mem_CS(Mem_CS),
                                    .MuxASel(MuxASel), .MuxBSel(MuxBSel), .MuxCSel(MuxCSel), .Clock(Clock));

// Assign IROut to IR
assign IR=_ALUSystem.IR.IROut;

// REGISTER INITIALIZATON
initial begin
  // PC starts from address 0x00 so it will be cleared before the first fetch & decode
  _ALUSystem.ARF.PC.Q=16'b0000000000000000;
  // SP is initialized to address 255
  _ALUSystem.ARF.SP.Q=16'b0000000011111111;
  // AR initialized to 0
  _ALUSystem.ARF.AR.Q=16'b0000000000000000;
  // General Purpose Registers initialized to 0
  _ALUSystem.RF.R1.Q=16'b0000000000000000;
  _ALUSystem.RF.R2.Q=16'b0000000000000000;
  _ALUSystem.RF.R3.Q=16'b0000000000000000;
  _ALUSystem.RF.R4.Q=16'b0000000000000000;
  _ALUSystem.RF.S1.Q=16'b0000000000000000;
  _ALUSystem.RF.S2.Q=16'b0000000000000000;
  _ALUSystem.RF.S3.Q=16'b0000000000000000;
  _ALUSystem.RF.S4.Q=16'b0000000000000000;

  SC=3'b000;
  CLR=1'b0; 
end

// Synchronous always block for SC
always @(negedge Clock) begin
  if ((!Reset) || CLR) 
    SC <= 3'b000;
  else
    SC <= SC + 3'b001;
  // Sequence Counter is incremented at positive edge of clock

CLR <= 1'b0;
end

always @(*) begin
  case (SC)
    3'b000:  T = 8'b00000001;
    3'b001:  T = 8'b00000010;
    3'b010:  T = 8'b00000100;
    3'b011:  T = 8'b00001000;
    3'b100:  T = 8'b00010000;
    3'b101:  T = 8'b00100000;
    3'b110:  T = 8'b01000000;
    3'b111:  T = 8'b10000000;
  endcase
end

always @(posedge Clock) begin
  // DISABLE SIGNALS   
  IR_WriteReg=1'b0;
  Mem_CSReg=1'b1;
  RF_RegSelReg=4'b1111;
  RF_ScrSelReg=4'b1111;
  ARF_RegSelReg=3'b111;
  if(!((IR[15:10] == 6'd4) || (IR[15:10] == 6'd19) || (IR[15:10] == 6'd33))) _ALUSystem.ALU.ALUOut = 16'b0000000000000000;
  #0.5;

  // Fetch and decode cycle
  if (T[0]) begin
    // PC gives the address to Memory
    ARF_OutDSelReg = 2'b00;
    // Read from memory
    Mem_CSReg = 1'b0;
    Mem_WRReg = 1'b0;
    #0.5;

    // Load LSB
    IR_LHReg = 1'b0;
    IR_WriteReg = 1'b1;

    // Increment PC
    ARF_RegSelReg=3'b011;
    ARF_FunSelReg=3'b001;
  end
  else if (T[1]) begin
    // DISABLE SIGNALS   
    IR_WriteReg=1'b0;
    Mem_CSReg=1'b1;
    RF_RegSelReg=4'b1111;
    RF_ScrSelReg=4'b1111;
    ARF_RegSelReg=3'b111; 
    #0.5;

    // PC gives the address to Memory
    ARF_OutDSelReg = 2'b00;
    // Read from memory
    Mem_CSReg = 1'b0;
    Mem_WRReg = 1'b0;
    #0.5;

    // Load MSB
    IR_LHReg = 1'b1;
    IR_WriteReg = 1'b1;

    // Increment PC
    ARF_RegSelReg=3'b011;
    ARF_FunSelReg=3'b001;
  end
  else begin
    // CHECK ADDRESSING MODE
    if (IR[15:10] == 6'b000000 || IR[15:10] == 6'b000001 || IR[15:10] == 6'b000010 || IR[15:10] == 6'b000011 ||
        IR[15:10] == 6'b000100 || IR[15:10] == 6'b010001 || IR[15:10] == 6'b010010 || IR[15:10] == 6'b010011 ||
        IR[15:10] == 6'b010100 || IR[15:10] == 6'b011110 || IR[15:10] == 6'b011111 || IR[15:10] == 6'b100000 ||
        IR[15:10] == 6'b100001)
      M = 1;
    else
       M = 0;

    // DECODE
    if (M) begin  // if mem reference
      if (_ALUSystem.MEM.WR) begin // Write
        case (IR[9:8])
          2'b00: RF_OutASelReg = 3'b000;
          2'b01: RF_OutASelReg = 3'b001;
          2'b10: RF_OutASelReg = 3'b010;
          2'b11: RF_OutASelReg = 3'b011;
        endcase
      end
      else begin  // Read
        case (IR[9:8])
          2'b00: RF_RegSelReg = 4'b0111;
          2'b01: RF_RegSelReg = 4'b1011;
          2'b10: RF_RegSelReg = 4'b1101;
          2'b11: RF_RegSelReg = 4'b1110;
        endcase
      end
    end
    else begin  // if register reference
      ALU_WFReg = _ALUSystem.IR.IROut[9];
      case (IR[8:6])  // DSTREG
        3'b000: ARF_RegSelReg = 3'b011;
        3'b001: ARF_RegSelReg = 3'b011;
        3'b010: ARF_RegSelReg = 3'b110;
        3'b011: ARF_RegSelReg = 3'b101;
        3'b100: RF_RegSelReg = 4'b0111;
        3'b101: RF_RegSelReg = 4'b1011;
        3'b110: RF_RegSelReg = 4'b1101;
        3'b111: RF_RegSelReg = 4'b1110;
      endcase
      case (IR[5:3])  // SREG1
        3'b000: ARF_OutCSelReg = 2'b00;
        3'b001: ARF_OutCSelReg = 2'b01;
        3'b010: ARF_OutCSelReg = 2'b11;
        3'b011: ARF_OutCSelReg = 2'b10;
        3'b100: RF_OutASelReg = 3'b000;
        3'b101: RF_OutASelReg = 3'b001;
        3'b110: RF_OutASelReg = 3'b010;
        3'b111: RF_OutASelReg = 3'b011;
      endcase
      case (IR[2:0])  // SREG2
        3'b000: ARF_OutCSelReg = 2'b00;
        3'b001: ARF_OutCSelReg = 2'b01;
        3'b010: ARF_OutCSelReg = 2'b11;
        3'b011: ARF_OutCSelReg = 2'b10;
        3'b100: RF_OutBSelReg = 3'b000;
        3'b101: RF_OutBSelReg = 3'b001;
        3'b110: RF_OutBSelReg = 3'b010;
        3'b111: RF_OutBSelReg = 3'b011;
      endcase
    end

    case(IR[15:10])
      6'd0: if(T[2]) begin MuxASelReg=2'b11; RF_RegSelReg=4'b1111; RF_ScrSelReg=4'b0111;  RF_FunSelReg=3'b100; end
            else if(T[3]) begin ARF_OutCSelReg=3'b000; MuxASelReg=2'b01; RF_RegSelReg=4'b1111; RF_ScrSelReg=4'b1011; RF_FunSelReg=3'b010;
            RF_OutASelReg=3'b100; RF_OutBSelReg=3'b101; ALU_FunSelReg=5'b10100; end
            else if(T[4]) begin RF_RegSelReg=4'b1111; MuxBSelReg=2'b00; ARF_FunSelReg=3'b010; ARF_RegSelReg=3'b011;
            CLR=1'b1; end
      6'd1: if(T[2] && !(_ALUSystem.ALU.FlagsOut[3])) begin  MuxBSelReg=2'b11; ARF_FunSelReg=3'b100; ARF_RegSelReg=3'b011;
            CLR=1'b1; end
      6'd2: if(T[2] && (_ALUSystem.ALU.FlagsOut[3])) begin MuxBSelReg=2'b11; ARF_FunSelReg=3'b100; ARF_RegSelReg=3'b011;
            CLR=1'b1; end
      6'd3: if(T[2]) begin ARF_RegSelReg=3'b110;  ARF_FunSelReg=3'b001; ARF_OutDSelReg=2'b11;
            Mem_CSReg=1'b0; Mem_WRReg=1'b0; MuxASelReg=2'b10; RF_FunSelReg=3'b110; end
            else if(T[3]) begin ARF_RegSelReg=3'b110;  ARF_FunSelReg=3'b001; ARF_OutDSelReg=2'b11;
            Mem_CSReg=1'b0; Mem_WRReg=1'b0; MuxASelReg=2'b10; RF_FunSelReg=3'b101;
            CLR=1'b1; end
      6'd4: if(T[2]) begin Mem_WRReg=1'b1; ARF_OutDSelReg=2'b11; ALU_FunSelReg=5'b10000; MuxCSelReg=1'b0; end
            else if(T[3]) begin Mem_WRReg=1'b1; ARF_OutDSelReg=2'b11; Mem_CSReg=1'b0; ALU_FunSelReg=5'b10000; MuxCSelReg=1'b0;
            ARF_RegSelReg=3'b110;  ARF_FunSelReg=3'b000; end
            else if(T[4]) begin Mem_WRReg=1'b1; ARF_OutDSelReg=2'b11; Mem_CSReg=1'b0; ALU_FunSelReg=5'b10000; MuxCSelReg=1'b1; 
            ARF_RegSelReg=3'b110;  ARF_FunSelReg=3'b000;
            CLR=1'b1; end
      6'd5: if(T[2]) begin if((!IR[5]) && (!IR[8])) begin MuxBSelReg=2'b01; ARF_FunSelReg=3'b010; end
            else if((!IR[5]) && (IR[8])) begin MuxASelReg=2'b01; RF_FunSelReg=3'b010; end
            else if((IR[5]) && (!IR[8])) begin ALU_FunSelReg=5'b10000; MuxBSelReg=2'b00; ARF_FunSelReg=3'b010; end
            else if((IR[5]) && (IR[8])) begin ALU_FunSelReg=5'b10000; MuxASelReg=2'b00; RF_FunSelReg=3'b010; end end
            else if(T[3]) begin if(!IR[8]) ARF_FunSelReg=3'b001;
            else RF_FunSelReg=3'b001;
            CLR=1'b1; end
      6'd6: if(T[2]) begin if((!IR[5]) && (!IR[8])) begin MuxBSelReg=2'b01; ARF_FunSelReg=3'b010; end
            else if((!IR[5]) && (IR[8])) begin MuxASelReg=2'b01; RF_FunSelReg=3'b010; end
            else if((IR[5]) && (!IR[8])) begin ALU_FunSelReg=5'b10000; MuxBSelReg=2'b00; ARF_FunSelReg=3'b010; end
            else if((IR[5]) && (IR[8])) begin ALU_FunSelReg=5'b10000; MuxASelReg=2'b00; RF_FunSelReg=3'b010; end end
            else if(T[3]) begin if(!IR[8]) ARF_FunSelReg=3'b000;
            else RF_FunSelReg=3'b000; 
            CLR=1'b1; end
      6'd7: if(T[2]) begin if(!IR[5]) begin MuxASelReg=2'b01;  RF_ScrSelReg=4'b0111;  RF_FunSelReg=3'b010;  RF_OutASelReg=3'b100; end
            ALU_FunSelReg=5'b11011;
            if(!IR[8]) begin MuxBSelReg=2'b00;  ARF_FunSelReg=3'b010; end
            else begin MuxASelReg=2'b00; RF_FunSelReg=3'b010; end
            CLR=1'b1; end
      6'd8: if(T[2]) begin if(!IR[5]) begin MuxASelReg=2'b01;  RF_ScrSelReg=4'b0111;  RF_FunSelReg=3'b010;  RF_OutASelReg=3'b100; end
            ALU_FunSelReg=5'b11100;
            if(!IR[8]) begin MuxBSelReg=2'b00;  ARF_FunSelReg=3'b010; end
            else begin MuxASelReg=2'b00; RF_FunSelReg=3'b010; end
            CLR=1'b1; end
      6'd9: if(T[2]) begin if(!IR[5]) begin MuxASelReg=2'b01;  RF_ScrSelReg=4'b0111;  RF_FunSelReg=3'b010;  RF_OutASelReg=3'b100; end
            ALU_FunSelReg=5'b11101;
            if(!IR[8]) begin MuxBSelReg=2'b00;  ARF_FunSelReg=3'b010; end
            else begin MuxASelReg=2'b00; RF_FunSelReg=3'b010; end
            CLR=1'b1; end
      6'd10: if(T[2]) begin if(!IR[5]) begin MuxASelReg=2'b01;  RF_ScrSelReg=4'b0111;  RF_FunSelReg=3'b010;  RF_OutASelReg=3'b100; end
             ALU_FunSelReg=5'b11110;
             if(!IR[8]) begin MuxBSelReg=2'b00;  ARF_FunSelReg=3'b010; end
             else begin MuxASelReg=2'b00; RF_FunSelReg=3'b010; end
             CLR=1'b1; end
      6'd11: if(T[2]) begin if(!IR[5]) begin MuxASelReg=2'b01;  RF_ScrSelReg=4'b0111;  RF_FunSelReg=3'b010;  RF_OutASelReg=3'b100; end
             ALU_FunSelReg=5'b11111;
             if(!IR[8]) begin MuxBSelReg=2'b00;  ARF_FunSelReg=3'b010; end
             else begin MuxASelReg=2'b00; RF_FunSelReg=3'b010; end
             CLR=1'b1; end
      6'd12: if(T[2]) begin RF_RegSelReg=4'b1111; if(!IR[5]) MuxASelReg=2'b01;
             else begin ALU_FunSelReg=5'b10000; MuxASelReg=2'b00; end
             RF_ScrSelReg=4'b0111;  RF_FunSelReg=3'b010; end
             else if(T[3]) begin if(!IR[2]) begin MuxASelReg=2'b01; RF_ScrSelReg=4'b1011; RF_FunSelReg=3'b010; RF_OutBSelReg=3'b101; end
             RF_OutASelReg=3'b100; ALU_FunSelReg = 5'b10111;
             if(!IR[8]) begin MuxBSelReg=2'b00;  ARF_FunSelReg=3'b010; end
             else begin MuxASelReg=2'b00; RF_FunSelReg=3'b010; end
             CLR=1'b1; end
      6'd13: if(T[2]) begin RF_RegSelReg=4'b1111; if(!IR[5]) MuxASelReg=2'b01;
             else begin ALU_FunSelReg=5'b10000; MuxASelReg=2'b00; end
             RF_ScrSelReg=4'b0111;  RF_FunSelReg=3'b010; end
             else if(T[3]) begin if(!IR[2]) begin MuxASelReg=2'b01; RF_ScrSelReg=4'b1011; RF_FunSelReg=3'b010; RF_OutBSelReg=3'b101; end
             RF_OutASelReg=3'b100; ALU_FunSelReg = 5'b11000;
             if(!IR[8]) begin MuxBSelReg=2'b00;  ARF_FunSelReg=3'b010; end
             else begin MuxASelReg=2'b00; RF_FunSelReg=3'b010; end
             CLR=1'b1; end
      6'd14: if(T[2]) begin RF_RegSelReg=4'b1111; if(!IR[5]) MuxASelReg=2'b01;
             else begin ALU_FunSelReg=5'b10000; MuxASelReg=2'b00; end
             RF_ScrSelReg=4'b0111;  RF_FunSelReg=3'b010; end
             else if(T[3]) begin RF_OutASelReg=3'b100; ALU_FunSelReg = 5'b10010;
             if(!IR[8]) begin MuxBSelReg=2'b00;  ARF_FunSelReg=3'b010; end
             else begin MuxASelReg=2'b00; RF_FunSelReg=3'b010; end
             CLR=1'b1; end
      6'd15: if(T[2]) begin RF_RegSelReg=4'b1111; if(!IR[5]) MuxASelReg=2'b01;
             else begin ALU_FunSelReg=5'b10000; MuxASelReg=2'b00; end
             RF_ScrSelReg=4'b0111;  RF_FunSelReg=3'b010; end
             else if(T[3]) begin if(!IR[2]) begin MuxASelReg=2'b01; RF_ScrSelReg=4'b1011; RF_FunSelReg=3'b010; RF_OutBSelReg=3'b101; end
             RF_OutASelReg=3'b100; ALU_FunSelReg = 5'b11001;
             if(!IR[8]) begin MuxBSelReg=2'b00;  ARF_FunSelReg=3'b010; end
             else begin MuxASelReg=2'b00; RF_FunSelReg=3'b010; end 
             CLR=1'b1; end
      6'd16: if(T[2]) begin RF_RegSelReg=4'b1111; if(!IR[5]) MuxASelReg=2'b01;
             else begin ALU_FunSelReg=5'b10000; MuxASelReg=2'b00; end
             RF_ScrSelReg=4'b0111;  RF_FunSelReg=3'b010; end
             else if(T[3]) begin if(!IR[2]) begin MuxASelReg=2'b01; RF_ScrSelReg=4'b1011; RF_FunSelReg=3'b010; RF_OutBSelReg=3'b101; end
             RF_OutASelReg=3'b100; ALU_FunSelReg = 5'b11010;
             if(!IR[8]) begin MuxBSelReg=2'b00;  ARF_FunSelReg=3'b010; end
             else begin MuxASelReg=2'b00; RF_FunSelReg=3'b010; end
             CLR=1'b1; end
      6'd17: if(T[2]) begin MuxASelReg=2'b11; RF_FunSelReg=3'b110;
             CLR=1'b1; end
      6'd18: if(T[2]) begin ARF_OutDSelReg=2'b10; Mem_CSReg=1'b0; Mem_WRReg=1'b0; MuxASelReg=2'b10; RF_FunSelReg=3'b101;
             ARF_RegSelReg=3'b101; ARF_FunSelReg=3'b001; end
             else if(T[3]) begin ARF_OutDSelReg=2'b10; Mem_CSReg=1'b0; Mem_WRReg=1'b0; MuxASelReg=2'b10; RF_FunSelReg=3'b110;
             ARF_RegSelReg=3'b101; ARF_FunSelReg=3'b000;
             CLR=1'b1; end 
      6'd19: if(T[2]) begin ARF_OutDSelReg=2'b10; Mem_WRReg=1'b1; ALU_FunSelReg=5'b10000; MuxCSelReg=1'b0; end
             else if(T[3]) begin ARF_OutDSelReg=2'b10; Mem_CSReg=1'b0; Mem_WRReg=1'b1; ALU_FunSelReg=5'b10000; MuxCSelReg=1'b0;
             ARF_RegSelReg=3'b101; ARF_FunSelReg=3'b001; end
             else if(T[4]) begin ARF_OutDSelReg=2'b10; Mem_CSReg=1'b0; Mem_WRReg=1'b1; ALU_FunSelReg=5'b10000; MuxCSelReg=1'b1;
             ARF_RegSelReg=3'b101; ARF_FunSelReg=3'b000;
             CLR=1'b1; end
      6'd20: if(T[2]) begin MuxASelReg=2'b11; RF_FunSelReg=3'b101;
             CLR=1'b1; end
      6'd21: if(T[2]) begin RF_RegSelReg=4'b1111; if(!IR[5]) MuxASelReg=2'b01;
             else begin ALU_FunSelReg=5'b10000; MuxASelReg=2'b00; end
             RF_ScrSelReg=4'b0111;  RF_FunSelReg=3'b010; end
             else if(T[3]) begin if(!IR[2]) begin MuxASelReg=2'b01; RF_ScrSelReg=4'b1011; RF_FunSelReg=3'b010; RF_OutBSelReg=3'b101; end
             RF_OutASelReg=3'b100; ALU_FunSelReg = 5'b10100;
             if(!IR[8]) begin MuxBSelReg=2'b00;  ARF_FunSelReg=3'b010; end
             else begin MuxASelReg=2'b00; RF_FunSelReg=3'b010; end 
             CLR=1'b1; end
      6'd22: if(T[2]) begin RF_RegSelReg=4'b1111; if(!IR[5]) MuxASelReg=2'b01;
             else begin ALU_FunSelReg=5'b10000; MuxASelReg=2'b00; end
             RF_ScrSelReg=4'b0111;  RF_FunSelReg=3'b010; end
             else if(T[3]) begin if(!IR[2]) begin MuxASelReg=2'b01; RF_ScrSelReg=4'b1011; RF_FunSelReg=3'b010; RF_OutBSelReg=3'b101; end
             RF_OutASelReg=3'b100; ALU_FunSelReg = 5'b10101;
             if(!IR[8]) begin MuxBSelReg=2'b00;  ARF_FunSelReg=3'b010; end
             else begin MuxASelReg=2'b00; RF_FunSelReg=3'b010; end 
             CLR=1'b1; end
      6'd23: if(T[2]) begin RF_RegSelReg=4'b1111; if(!IR[5]) MuxASelReg=2'b01;
             else begin ALU_FunSelReg=5'b10000; MuxASelReg=2'b00; end
             RF_ScrSelReg=4'b0111;  RF_FunSelReg=3'b010; end
             else if(T[3]) begin if(!IR[2]) begin MuxASelReg=2'b01; RF_ScrSelReg=4'b1011; RF_FunSelReg=3'b010; RF_OutBSelReg=3'b101; end
             RF_OutASelReg=3'b100; ALU_FunSelReg = 5'b10110;
             if(!IR[8]) begin MuxBSelReg=2'b00;  ARF_FunSelReg=3'b010; end
             else begin MuxASelReg=2'b00; RF_FunSelReg=3'b010; end 
             CLR=1'b1; end
      6'd24: if(T[2]) begin if(!IR[5]) MuxASelReg=2'b01;
             else begin ALU_FunSelReg=5'b10000; MuxASelReg=2'b00; end
             RF_ScrSelReg=4'b0111;  RF_FunSelReg=3'b010; end
             else if(T[3]) begin RF_OutASelReg=3'b100; ALU_FunSelReg = 5'b10000;
             if(!IR[8]) begin MuxBSelReg=2'b00;  ARF_FunSelReg=3'b010; end
             else begin MuxASelReg=2'b00; RF_FunSelReg=3'b010; end
             CLR=1'b1; end
      6'd25: if(T[2]) begin RF_RegSelReg=4'b1111; if(!IR[5]) MuxASelReg=2'b01;
             else begin ALU_FunSelReg=5'b10000; MuxASelReg=2'b00; end
             RF_ScrSelReg=4'b0111;  RF_FunSelReg=3'b010; end
             else if(T[3]) begin if(!IR[2]) begin MuxASelReg=2'b01; RF_ScrSelReg=4'b1011; RF_FunSelReg=3'b010; RF_OutBSelReg=3'b101; end
             RF_OutASelReg=3'b100; ALU_FunSelReg = 5'b10100;
             if(!IR[8]) begin MuxBSelReg=2'b00;  ARF_FunSelReg=3'b010; end
             else begin MuxASelReg=2'b00; RF_FunSelReg=3'b010; end 
             CLR=1'b1; end
      6'd26: if(T[2]) begin RF_RegSelReg=4'b1111; if(!IR[5]) MuxASelReg=2'b01;
             else begin ALU_FunSelReg=5'b10000; MuxASelReg=2'b00; end
             RF_ScrSelReg=4'b0111;  RF_FunSelReg=3'b010; end
             else if(T[3]) begin if(!IR[2]) begin MuxASelReg=2'b01; RF_ScrSelReg=4'b1011; RF_FunSelReg=3'b010; RF_OutBSelReg=3'b101; end
             RF_OutASelReg=3'b100; ALU_FunSelReg = 5'b10110;
             if(!IR[8]) begin MuxBSelReg=2'b00;  ARF_FunSelReg=3'b010; end
             else begin MuxASelReg=2'b00; RF_FunSelReg=3'b010; end 
             CLR=1'b1; end
      6'd27: if(T[2]) begin RF_RegSelReg=4'b1111; if(!IR[5]) MuxASelReg=2'b01;
             else begin ALU_FunSelReg=5'b10000; MuxASelReg=2'b00; end
             RF_ScrSelReg=4'b0111;  RF_FunSelReg=3'b010; end
             else if(T[3]) begin if(!IR[2]) begin MuxASelReg=2'b01; RF_ScrSelReg=4'b1011; RF_FunSelReg=3'b010; RF_OutBSelReg=3'b101; end
             RF_OutASelReg=3'b100; ALU_FunSelReg = 5'b10111;
             if(!IR[8]) begin MuxBSelReg=2'b00;  ARF_FunSelReg=3'b010; end
             else begin MuxASelReg=2'b00; RF_FunSelReg=3'b010; end
             CLR=1'b1; end
      6'd28: if(T[2]) begin RF_RegSelReg=4'b1111; if(!IR[5]) MuxASelReg=2'b01;
             else begin ALU_FunSelReg=5'b10000; MuxASelReg=2'b00; end
             RF_ScrSelReg=4'b0111;  RF_FunSelReg=3'b010; end
             else if(T[3]) begin if(!IR[2]) begin MuxASelReg=2'b01; RF_ScrSelReg=4'b1011; RF_FunSelReg=3'b010; RF_OutBSelReg=3'b101; end
             RF_OutASelReg=3'b100; ALU_FunSelReg = 5'b11000;
             if(!IR[8]) begin MuxBSelReg=2'b00;  ARF_FunSelReg=3'b010; end
             else begin MuxASelReg=2'b00; RF_FunSelReg=3'b010; end
             CLR=1'b1; end
      6'd29: if(T[2]) begin RF_RegSelReg=4'b1111; if(!IR[5]) MuxASelReg=2'b01;
             else begin ALU_FunSelReg=5'b10000; MuxASelReg=2'b00; end
             RF_ScrSelReg=4'b0111;  RF_FunSelReg=3'b010; end
             else if(T[3]) begin if(!IR[2]) begin MuxASelReg=2'b01; RF_ScrSelReg=4'b1011; RF_FunSelReg=3'b010; RF_OutBSelReg=3'b101; end
             RF_OutASelReg=3'b100; ALU_FunSelReg = 5'b11001;
             if(!IR[8]) begin MuxBSelReg=2'b00;  ARF_FunSelReg=3'b010; end
             else begin MuxASelReg=2'b00; RF_FunSelReg=3'b010; end 
             CLR=1'b1; end
      6'd30: if(T[2]) begin RF_RegSelReg=4'b1111; ARF_OutCSelReg=2'b00; MuxASelReg=2'b01; RF_ScrSelReg=4'b0111; RF_FunSelReg=3'b010; end
             else if(T[3]) begin RF_RegSelReg=4'b1111; ARF_OutDSelReg=2'b11; Mem_CSReg=1'b0; Mem_WRReg=1'b1;
             RF_OutASelReg=3'b100; ALU_FunSelReg=5'b10000; MuxCSelReg=1'b0;
             ARF_RegSelReg=3'b110; ARF_FunSelReg=3'b000; end
             else if(T[4]) begin RF_RegSelReg=4'b1111; ARF_OutCSelReg=2'b00; MuxASelReg=2'b01; RF_ScrSelReg=4'b0111; RF_FunSelReg=3'b010; end
             else if(T[5]) begin ARF_OutDSelReg=2'b11; Mem_CSReg=1'b0; Mem_WRReg=1'b1;
             RF_OutASelReg=3'b100; ALU_FunSelReg=5'b10000; MuxCSelReg=1'b1;
             ARF_RegSelReg=3'b110; ARF_FunSelReg=3'b000; end 
             else if(T[6]) begin ALU_FunSelReg=5'b10000; MuxBSelReg=2'b00; ARF_RegSelReg=3'b011; ARF_FunSelReg=3'b010;
             CLR=1'b1; end
      6'd31: if(T[2]) begin ARF_FunSelReg=3'b001; ARF_RegSelReg=3'b110; end
             else if(T[3]) begin ARF_OutDSelReg=2'b11; Mem_CSReg=1'b0; Mem_WRReg=1'b0; MuxBSelReg=2'b10; 
             ARF_RegSelReg=3'b011; ARF_FunSelReg=3'b110; end
             else if(T[4]) begin ARF_FunSelReg=3'b001; ARF_RegSelReg=3'b110; end
             else if(T[5]) begin ARF_OutDSelReg=2'b11; Mem_CSReg=1'b0; Mem_WRReg=1'b0; MuxBSelReg=2'b10;
             ARF_RegSelReg=3'b011; ARF_FunSelReg=3'b101;
             CLR=1'b1; end
      6'd32: if(T[2]) begin MuxBSelReg=2'b11; ARF_RegSelReg=3'b101; ARF_FunSelReg=3'b100; end
             else if(T[3]) begin ARF_OutDSelReg=2'b10; Mem_CSReg=1'b0; Mem_WRReg=1'b0;
             MuxASelReg=2'b10; RF_FunSelReg=3'b101;
             ARF_RegSelReg=3'b101; ARF_FunSelReg=3'b001; end 
             else if(T[4]) begin ARF_OutDSelReg=2'b10; Mem_CSReg=1'b0; Mem_WRReg=1'b0;
             MuxASelReg=2'b10; RF_FunSelReg=3'b110;
             CLR=1'b1; end 
      6'd33: if(T[2]) begin RF_RegSelReg=4'b1111; ARF_OutCSelReg=2'b10; MuxASelReg=2'b01;
             RF_ScrSelReg=4'b0111;  RF_FunSelReg=3'b010; end
             else if(T[3]) begin RF_RegSelReg=4'b1111; MuxASelReg=2'b11; RF_ScrSelReg=4'b1011; RF_FunSelReg=3'b100; end
             else if(T[4]) begin RF_RegSelReg=4'b1111; RF_OutASelReg=3'b100; RF_OutBSelReg=3'b101; ALU_FunSelReg=5'b10100;
             MuxBSelReg=2'b00; ARF_RegSelReg=3'b101; ARF_FunSelReg=3'b010; end
             else if(T[5]) begin RF_RegSelReg=4'b1111; ARF_OutDSelReg=2'b10; Mem_WRReg=1'b1; end 
             else if(T[6]) begin RF_RegSelReg=4'b1111; ARF_OutDSelReg=2'b10; Mem_CSReg=1'b0; Mem_WRReg=1'b1;
             MuxCSelReg=1'b0; ALU_FunSelReg=5'b10000;
             ARF_RegSelReg=3'b101; ARF_FunSelReg=3'b001; end 
             else if(T[7]) begin ARF_OutDSelReg=2'b10; Mem_CSReg=1'b0; Mem_WRReg=1'b1;
             MuxCSelReg=1'b1; ALU_FunSelReg=5'b10000;
             CLR=1'b1; end
    endcase
  end
end

endmodule
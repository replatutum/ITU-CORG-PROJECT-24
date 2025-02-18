// EMRE YAMAC 150210077
// ALPER TUTUM 150210088

`timescale 1ns/1ps

module ArithmeticLogicUnit(
  input wire[15:0] A,
  input wire[15:0] B,

  input wire[4:0] FunSel,
  input wire WF,

  input wire Clock,

  output reg[15:0] ALUOut,
  output reg[3:0] FlagsOut
  //Z | C | N | O
  //Z = zero
  //C = carry
  //N = negative
  //O = overflow
);

reg CF;         //temporary carry flag
reg[16:0] temp; //temporary register for arithmetic and shift operations

//always block for ALUOut
always @(*) begin  
  temp = {16{1'b0}};  
  case (FunSel)
    //8-bit operations
    5'b00000: ALUOut[7:0] = A[7:0];  //A
    5'b00001: ALUOut[7:0] = B[7:0];  //B
    5'b00010: ALUOut[7:0] = ~A[7:0]; //Compelement A 
    5'b00011: ALUOut[7:0] = ~B[7:0]; //Complement B
    5'b00100: begin //A+B
      temp = A[7:0] + B[7:0];
      CF = temp[8];
      ALUOut[7:0] = temp[7:0];
    end  
    5'b00101:begin  //A+B+Carry
      temp = A[7:0] + B[7:0] + FlagsOut[2];
      CF = temp[8];
      ALUOut[7:0] = temp[7:0];
    end
    5'b00110: begin //A-B
      temp = A[7:0] + ~B[7:0] + 1;
      CF = temp[8];
      ALUOut[7:0] = temp [7:0];
    end
    5'b00111: ALUOut[7:0] = A[7:0] & B[7:0];          //A AND B 
    5'b01000: ALUOut[7:0] = A[7:0] | B[7:0];          //A OR B 
    5'b01001: ALUOut[7:0] = A[7:0] ^ B[7:0];          //A XOR B 
    5'b01010: ALUOut[7:0] = (~A[7:0]) | (~B[7:0]);    //A NAND B
    5'b01011: begin //LSL
      CF = A[7];
      ALUOut[7:1] = A[6:0];
      ALUOut[0] = 1'b0;
    end
    5'b01100: begin //LSR
      CF = A[0];
      ALUOut[6:0] = A[7:1];
      ALUOut[7] = 1'b0;
    end
    5'b01101: begin //ASR
      CF = A[0];
      ALUOut[7] = A[7];
      ALUOut[6:0] = A[7:1];
    end
    5'b01110: begin //CSL
      CF = A[7];
      ALUOut[7:1] = A[6:0];
      ALUOut[0] = FlagsOut[2];
    end
    5'b01111: begin //CSR
      CF = A[0];
      ALUOut[7] = FlagsOut[2];
      ALUOut[6:0] = A[7:1];
    end

    //16-bit operations
    5'b10000: ALUOut = A;   //A
    5'b10001: ALUOut = B;   //B
    5'b10010: ALUOut = ~A;  //Complement A
    5'b10011: ALUOut = ~B;  //Complement B
    5'b10100: begin //A+B
      temp = A + B;
      ALUOut = temp[15:0];
      CF = temp[16];
    end
    5'b10101: begin //A+B+Carry
      temp = A + B + FlagsOut[2];
      ALUOut = temp[15:0];
      CF = temp[16];
    end
    5'b10110:begin  //A-B
      temp = A + (~B) + 1;
      ALUOut = temp[15:0];
      CF = temp[16];
    end
    5'b10111: ALUOut = A & B;           //A AND B
    5'b11000: ALUOut = A | B;           //A OR B
    5'b11001: ALUOut = A ^ B;           //A XOR B
    5'b11010: ALUOut = (~A) | (~B);     //A NAND B
    5'b11011: begin //LSL
      CF = A[15];
      ALUOut[15:1] = A[14:0]; 
      ALUOut[0] = 1'b0; 
    end
    5'b11100: begin //LSR
      CF = A[0];
      ALUOut[14:0] = A[15:1]; 
      ALUOut[15] = 1'b0;
    end
    5'b11101: begin //ASR
      CF = A[0];
      ALUOut[14:0] = A[15:1];
      ALUOut[15] = A[15];
    end
    5'b11110: begin //CSL
      CF = A[15];
      ALUOut[15:1] = A[14:0];
      ALUOut[0] = FlagsOut[2];
    end
    5'b11111: begin //CSR
      CF = A[0];
      ALUOut[14:0] = A[15:1];
      ALUOut[15] = FlagsOut[2];
    end
  endcase
end

//Always block with clock for FlagsOut
always @(posedge Clock) begin
  if (WF)begin
    case (FunSel)
      //Operations for LSB 8 bits
      5'b00000:begin //A
        if (ALUOut[7:0] == 8'b00000000)  //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[7] == 1)              //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        FlagsOut[2] <= FlagsOut[2];
        FlagsOut[0] <= FlagsOut[0];
      end
      5'b00001:begin //B
        if (ALUOut[7:0] == 8'b00000000)  //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[7] == 1)              //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        FlagsOut[2] <= FlagsOut[2];
        FlagsOut[0] <= FlagsOut[0];
      end
      5'b00010:begin //~A
        if (ALUOut[7:0] == 8'b00000000)  //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[7] == 1)              //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        FlagsOut[2] <= FlagsOut[2];
        FlagsOut[0] <= FlagsOut[0];
      end
      5'b00011:begin //~B
        if (ALUOut[7:0] == 8'b00000000)  //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[7] == 1)              //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        FlagsOut[2] <= FlagsOut[2];
        FlagsOut[0] <= FlagsOut[0];
      end
      5'b00100:begin //A+B
        FlagsOut[2] <= CF;                      //assign temp carry flag to C
        if (ALUOut[7:0] == 8'b00000000)         //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[7] == 1'b1)                  //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        if ((A[7] == B[7]) && (ALUOut[7]^A[7])) //check O
          FlagsOut[0] <= 1'b1;
        else
          FlagsOut[0] <= 1'b0;
      end
      5'b00101:begin //A+B+C
        FlagsOut[2] <= CF;                     //assign temp carry flag to C
        if (ALUOut[7:0] == 8'b00000000)        //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[7] == 1'b1)                 //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        if ((A[7] == B[7]) && (ALUOut[7]^A[7]))//check O
          FlagsOut[0] <= 1'b1;
        else
          FlagsOut[0] <= 1'b0;
      end
      5'b00110:begin  //A-B
        FlagsOut[2] <= CF;                     //assign temp carry flag to C
        if (ALUOut[7:0] == 8'b00000000)        //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[7] == 1'b1)                 //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        if ((A[7]^B[7]) && (ALUOut[7]^A[7]))   //check O
          FlagsOut[0] <= 1'b1;
        else
          FlagsOut[0] <= 1'b0;
      end
      5'b00111:begin  //AND
        if (ALUOut[7:0] == 8'b00000000)        //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[7] == 1)                    //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        FlagsOut[2] <= FlagsOut[2];
        FlagsOut[0] <= FlagsOut[0];
      end
      5'b01000:begin  //OR
        if (ALUOut[7:0] == 8'b00000000)        //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[7] == 1)                    //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        FlagsOut[2] <= FlagsOut[2];
        FlagsOut[0] <= FlagsOut[0];
      end
      5'b01001:begin  //XOR
        if (ALUOut[7:0] == 8'b00000000)        //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[7] == 1)                    //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        FlagsOut[2] <= FlagsOut[2];
        FlagsOut[0] <= FlagsOut[0];
      end
      5'b01010:begin  //NAND
        if (ALUOut[7:0] == 8'b00000000)        //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[7] == 1)                    //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        FlagsOut[2] = FlagsOut[2];
        FlagsOut[0] = FlagsOut[0];
      end
      5'b01011:begin  //LSL A
        FlagsOut[2] <= CF;                     //assign temp carry flag to C
        if (ALUOut[7:0] == 8'b00000000)        //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[7] == 1)                    //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        FlagsOut[0] <= FlagsOut[0];
      end
      5'b01100:begin  //LSR A
        FlagsOut[2] <= CF;                     //assign temp carry flag to C
        if (ALUOut[7:0] == 8'b00000000)        //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[7] == 1)                    //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        FlagsOut[0] <= FlagsOut[0];
      end
      5'b01101:begin  //ASR A
        FlagsOut[2] <= CF;                     //assign temp carry flag to C
        if (ALUOut[7:0] == 8'b00000000)        //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        FlagsOut[1] <= FlagsOut[1];
        FlagsOut[0] <= FlagsOut[0];
      end
      5'b01110:begin  //CSL A
        FlagsOut[2] <= CF;                     //assign temp carry flag to C
        if (ALUOut[7:0] == 8'b00000000)        //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[7] == 1)                    //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        FlagsOut[0] <= FlagsOut[0];
      end
      5'b01111:begin  //CSR A
        FlagsOut[2] <= CF;                     //assign temp carry flag to C
        if (ALUOut[7:0] == 8'b00000000)        //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[7] == 1)                    //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        FlagsOut[0] <= FlagsOut[0];
      end

      //Operations for full 16 bits
      5'b10000:begin  //A
        if (ALUOut == 16'b0000000000000000)        //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[15] == 1)                       //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        FlagsOut[2] <= FlagsOut[2];
        FlagsOut[0] <= FlagsOut[0];
      end
      5'b10001:begin //B
        if (ALUOut == 16'b0000000000000000)        //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[15] == 1)                       //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        FlagsOut[2] <= FlagsOut[2];
        FlagsOut[0] <= FlagsOut[0];
      end
      5'b10010:begin //~A
        if (ALUOut == 16'b0000000000000000)        //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[15] == 1)                       //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        FlagsOut[2] <= FlagsOut[2];
        FlagsOut[0] <= FlagsOut[0];
      end
      5'b10011:begin  //~B
        if (ALUOut == 16'b0000000000000000)        //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[15] == 1)                       //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        FlagsOut[2] <= FlagsOut[2];
        FlagsOut[0] <= FlagsOut[0];
      end
      5'b10100:begin  //A+B
        FlagsOut[2] <= CF;                           //assign temp carry flag to C
        if (ALUOut == 16'b0000000000000000)          //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[15] == 1'b1)                      //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        if ((A[15] == B[15]) && (ALUOut[15]^A[15]))  //check O
          FlagsOut[0] <= 1'b1;
        else
          FlagsOut[0] <= 1'b0;
      end
      5'b10101:begin  //A+B+C
        FlagsOut[2] <= CF;                            //assign temp carry flag to C
        if (ALUOut == 16'b0000000000000000)           //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[15] == 1'b1)                       //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        if ((A[15] == B[15]) && (ALUOut[15]^A[15]))   //check O
          FlagsOut[0] <= 1'b1;
        else
          FlagsOut[0] <= 1'b0;
      end
      5'b10110:begin  //A-B
        FlagsOut[2] <= CF;                            //assign temp carry flag to C
        if (ALUOut == 16'b0000000000000000)           //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[15] == 1'b1)                       //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        if ((A[15]^B[15]) && (ALUOut[15]^A[15]))      //check O
          FlagsOut[0] <= 1'b1;
        else
          FlagsOut[0] <= 1'b0;
      end
      5'b10111:begin  //AND
        if (ALUOut == 16'b0000000000000000)           //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[15] == 1)                          //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        FlagsOut[2] <= FlagsOut[2];
        FlagsOut[0] <= FlagsOut[0];
      end
      5'b11000:begin  //OR
        if (ALUOut == 16'b0000000000000000)           //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[15] == 1)                          //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        FlagsOut[2] <= FlagsOut[2];
        FlagsOut[0] <= FlagsOut[0];
      end
      5'b11001:begin  //XOR
        if (ALUOut == 16'b0000000000000000)           //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[15] == 1)                          //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        FlagsOut[2] <= FlagsOut[2];
        FlagsOut[0] <= FlagsOut[0];
      end
      5'b11010:begin  //NAND
        if (ALUOut == 16'b0000000000000000)           //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[15] == 1)                          //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        FlagsOut[2] <= FlagsOut[2];
        FlagsOut[0] <= FlagsOut[0];
      end
      5'b11011:begin  //LSL A
        FlagsOut[2] <= CF;                         //assign temp carry flag to C
        if (ALUOut == 16'b0000000000000000)        //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[15] == 1)                      //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        FlagsOut[0] <= FlagsOut[0];
      end
      5'b11100:begin  //LSR A
        FlagsOut[2] <= CF;                         //assign temp carry flag to C
        if (ALUOut == 16'b0000000000000000)        //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[15] == 1)                       //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        FlagsOut[0] <= FlagsOut[0];
      end
      5'b11101:begin  //ASR A 
        FlagsOut[2] <= CF;                         //assign temp carry flag to C
        if (ALUOut == 16'b0000000000000000)        //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        FlagsOut[1] <= FlagsOut[1];
        FlagsOut[0] <= FlagsOut[0];
      end
      5'b11110:begin  //CSL A
        FlagsOut[2] <= CF;                         //assign temp carry flag to C
        if (ALUOut == 16'b0000000000000000)        //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[15] == 1)                       //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        FlagsOut[0] <= FlagsOut[0];
      end
      5'b11111:begin  //CSR A
        FlagsOut[2] <= CF;                         //assign temp carry flag to C
        if (ALUOut == 16'b0000000000000000)        //check Z
          FlagsOut[3] <= 1'b1;
        else
          FlagsOut[3] <= 1'b0;
        if (ALUOut[15] == 1)                       //check N
          FlagsOut[1] <= 1'b1;
        else
          FlagsOut[1] <= 1'b0;
        FlagsOut[0] <= FlagsOut[0];
      end
    endcase
  end
end

endmodule
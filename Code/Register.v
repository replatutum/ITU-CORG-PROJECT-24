// EMRE YAMAC 150210077
// ALPER TUTUM 150210088
`timescale 1ns / 1ps

module Register(

input wire [15:0] I,
input wire E,
input wire [2:0] FunSel,
input wire Clock,
output reg [15:0] Q
);

always @(posedge Clock) begin
  if(E)
  begin
  case(FunSel)
   3'b000: Q <= Q-1;
   3'b001: Q <= Q+1; 
   3'b010: Q <= I;
   3'b011: Q <= 16'b0000000000000000;
   3'b100: begin Q[15:8] <= 8'b00000000;
                 Q[7:0]  <= I[7:0]; end 
   3'b101: Q[7:0] <= I[7:0];
   3'b110: Q[15:8] <= I[7:0];
   3'b111: begin 
       if (I[7] == 1)
           Q[15:8] <= {8{1'b1}};
       else
           Q[15:8] <= {8{1'b1}};
        Q[7:0] <= I[7:0]; 
       end    
    endcase       
   end
  else 
    Q <= Q; 
end

endmodule         
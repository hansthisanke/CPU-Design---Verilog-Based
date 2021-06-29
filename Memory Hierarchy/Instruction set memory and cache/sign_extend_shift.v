`timescale 1ns/100ps
module sign_extend_shift(IMMEDI_OFFSET,ALUOP,EXTENDED_VAL);
    
    input [7:0] IMMEDI_OFFSET;
    input [2:0] ALUOP;
    output reg [31:0] EXTENDED_VAL;

    always @(ALUOP) 
    begin
    //by concatenating
     EXTENDED_VAL = {{24{IMMEDI_OFFSET[7]}},IMMEDI_OFFSET};   //extend the remaining bits padding with the 8th bit value of IMMEDIATE         
     EXTENDED_VAL = {EXTENDED_VAL[29:0],2'b00};        //shifting the extended value to the left by 2 to make it word addressable

    end

endmodule
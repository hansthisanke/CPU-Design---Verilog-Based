`timescale 1ns/100ps
module mux_immediate(IMMEDIATE_VAL,REGOUT,IMMEDMUX_SEL,mux_immeOUT);
    
    input [7:0] IMMEDIATE_VAL,REGOUT;
    input IMMEDMUX_SEL;               //control signal for the immediate value select mux
    output reg [7:0] mux_immeOUT;     //output the result of the mux

    always @ (IMMEDIATE_VAL,REGOUT,IMMEDMUX_SEL)
    begin
      if(IMMEDMUX_SEL == 1'b0)
      begin
        mux_immeOUT = REGOUT;       //output the REGOUT value from the register
      end else begin
        mux_immeOUT= IMMEDIATE_VAL;   //output the Immediate value 
      end
    end

endmodule
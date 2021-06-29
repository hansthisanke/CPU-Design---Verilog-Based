`timescale 1ns/100ps
module mux_twoscomp(REGOUT2,inv_REGOUT2,TWOSCOMPMUX_SEL,mux_twosOUT);
    
    input [7:0] REGOUT2,inv_REGOUT2;
    input TWOSCOMPMUX_SEL;      //control signal for the 2's compliment select mux
    output reg [7:0] mux_twosOUT;     //output the result of the mux

    always @ (REGOUT2,inv_REGOUT2,TWOSCOMPMUX_SEL)
    begin
      if(TWOSCOMPMUX_SEL == 1'b0)
      begin
        mux_twosOUT = REGOUT2;          //output the REGOUT2 value
      end else begin
        mux_twosOUT= inv_REGOUT2;       //output the two's compliment of REGOUT2 value(for sub instruction)
      end
    end

endmodule
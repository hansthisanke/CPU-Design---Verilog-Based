module mux_write(ALURESULT,READDATA,WRITEMUX_SEL,mux_writeOUT);
 
 input [7:0] ALURESULT,READDATA; 
 input WRITEMUX_SEL;                //control signal for write select mux
 output reg [7:0] mux_writeOUT;        //output the result of the mux

 always @ (ALURESULT,READDATA,WRITEMUX_SEL)
 begin
    if (WRITEMUX_SEL == 1'b0) 
    begin
        mux_writeOUT = ALURESULT;       //output the ALU result without going through data memory     
    end else begin
        mux_writeOUT = READDATA;        //output data value read from the memory, at the location pointed to by ADDRESS
    end
 end




endmodule
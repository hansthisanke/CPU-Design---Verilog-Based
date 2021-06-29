/*
module testbench;
    reg [7:0] OPERAND1,OPERAND2;
    reg [2:0] ALUOP;
    wire [7:0] ALURESULT;

    alu myALU(OPERAND1,OPERAND2,ALURESULT,ALUOP);       //alu module is instantiated with the name myALU in the testbench module

    initial
    begin
        //see how signals vary using command line
        $monitor($time," OPERAND1: %8b ,OPERAND2: %8b ,ALUOP: %3b ,ALURESULT: %8b", OPERAND1,OPERAND2,ALUOP,ALURESULT);

        //generate files needed to plot the waveform using GTKwave
        $dumpfile("wavedataALU.vcd");
        $dumpvars(0,testbench);
    end

    initial
    begin
        OPERAND1 = 8'b00001100;      //initially set to 12(for example)
        OPERAND2 = 8'b00000010;      //initially set to 2
        ALUOP = 3'b000;          

        #10   //10 seconds time gap 
        ALUOP = 3'b001;          //changing ALUOP to run different instructions

        #10   //10 seconds time gap
        OPERAND1 =  8'b00001110;     //change OPERAND1 to 14(for example) 
        ALUOP = 3'b010;

        #10   //10 seconds time gap 
        ALUOP = 3'b011;

        #10   //10 seconds time gap 
        ALUOP = 3'b100;
   
    end
endmodule
*/

`timescale 1ns/100ps
module alu(DATA1,DATA2,RESULT,SELECT,ZERO);
    //ports declaration
    input [7:0] DATA1,DATA2;            //two 8-bit input ports for operands
    input [2:0] SELECT;                 //one 3-bit control input port for selecting each function
    output reg [7:0] RESULT;               //one 8-bit output port
    output ZERO;             

    wire [7:0] FORWARD_DATA,ADD_DATA,AND_DATA,OR_DATA,JUMP_DATA;
    //latencies added  
    assign #1 FORWARD_DATA = DATA2;
    assign #2 ADD_DATA = DATA1+DATA2;
    assign #1 AND_DATA = DATA1 & DATA2;
    assign #1 OR_DATA = DATA1 | DATA2;
    assign #1 JUMP_DATA = 8'b0; 

    always @(*)         //case statement executes when any of the inputs change during the program  
    begin     
        case (SELECT)                                  
            3'b000: RESULT =  FORWARD_DATA;             //FORWARD Function(loadi,mov,load,store) forward DATA2 into RESULT
            3'b001: RESULT =  ADD_DATA;                 //ADD Function(add,sub)        
            3'b010: RESULT =  AND_DATA;                 //bitwise AND
            3'b011: RESULT =  OR_DATA;                  //bitwise OR
            3'b100: RESULT = JUMP_DATA;                 // result made zero (then ZERO = 1 but won't affect since JUMPENABLE = 1 and BRANCHENABLE = 0 )
            default: RESULT = 8'bx;                     //RESULT set to 'X' for any other SELECT value(used for future functional units)
        endcase
    end
    
    assign ZERO = ~|RESULT;        //assigning ZERO with the result to identify if its a branch/jump signal
                                   //if ZERO = 1 and BRANCHENABLE = 1 , new PC is used to branch

endmodule
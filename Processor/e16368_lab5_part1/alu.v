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


module alu(DATA1,DATA2,RESULT,SELECT);
    //ports declaration
    input [7:0] DATA1,DATA2;            //two 8-bit input ports for operands
    input [2:0] SELECT;                 //one 3-bit control input port for selecting each function
    output reg [7:0] RESULT;            //one 8-bit output port

    always @(DATA1,DATA2,SELECT)         //case statement executes when any of the inputs change during the program  
    begin     
        case (SELECT)                              //latencies added      
            3'b000: RESULT = #1 DATA2;             //FORWARD Function(loadi,mov) forward DATA2 into RESULT
            3'b001: RESULT = #2 DATA1+DATA2;       //ADD Function(add,sub) 
            3'b010: RESULT = #1 DATA1 & DATA2;     //bitwise AND
            3'b011: RESULT = #1 DATA1 | DATA2;     //bitwise OR
            default: RESULT = 8'bx;                //RESULT set to 'X' for any other SELECT value(used for future functional units)
        endcase
    end

endmodule
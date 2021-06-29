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


module alu(DATA1,DATA2,RESULT,SELECT,ZERO);
    //ports declaration
    input [7:0] DATA1,DATA2;            //two 8-bit input ports for operands
    input [2:0] SELECT;                 //one 3-bit control input port for selecting each function
    output reg [7:0] RESULT;               //one 8-bit output port
    reg [7:0] temp;                     //temperory register to store shifted values 
    output ZERO;            

    always @(DATA1,DATA2,SELECT)         //case statement executes when any of the inputs change during the program  
    begin     
        temp = 8'bx;
        case (SELECT)                              //latencies added      
            3'b000: #1 RESULT =  DATA2;             //FORWARD Function(loadi,mov) forward DATA2 into RESULT
            3'b001: #2 RESULT =  DATA1+DATA2;       //ADD Function(add,sub)        
            3'b010: #1 RESULT =  DATA1 & DATA2;     //bitwise AND
            3'b011: #1 RESULT =  DATA1 | DATA2;     //bitwise OR
            3'b100: #1 RESULT = 8'b0;               // for jump result made zero (then ZERO gets equal to  1 but won't affect since PCMUX_SEL does not enables(equals one)

            3'b101: begin              //Logical left shift(sll)
                        #1;         //#1 time delay for shifting left
                        case (DATA2)                            //using concatination shifted values
                            8'd0: temp = DATA1[7:0];
                            8'd1: temp = {DATA1[6:0],1'b0};
                            8'd2: temp = {DATA1[5:0],2'b0};
                            8'd3: temp = {DATA1[4:0],3'b0};
                            8'd4: temp = {DATA1[3:0],4'b0};
                            8'd5: temp = {DATA1[2:0],5'b0};
                            8'd6: temp = {DATA1[1:0],6'b0};
                            8'd7: temp = {DATA1[0],7'b0};
                            8'd8: temp = 8'b0;     
                            default: temp = 8'bx;
                        endcase
                        RESULT = temp;              //store the shifted value into the RESULT output port
                    end
            3'b110: begin              //Logical right shift(srl)
                        #1;         //#1 time delay for shifting right
                        case (DATA2)                            //using concatination shifted values
                            8'd0: temp = DATA1[7:0];
                            8'd1: temp = {1'b0,DATA1[7:1]};
                            8'd2: temp = {2'b0,DATA1[7:2]};
                            8'd3: temp = {3'b0,DATA1[7:3]};
                            8'd4: temp = {4'b0,DATA1[7:4]};
                            8'd5: temp = {5'b0,DATA1[7:5]};
                            8'd6: temp = {6'b0,DATA1[7:6]};
                            8'd7: temp = {7'b0,DATA1[7]};
                            8'd8: temp = 8'b0;     
                            default: temp = 8'bx;
                        endcase
                        RESULT = temp;              //store the shifted value into the RESULT output port
                    end        
            default: RESULT = 8'bx;                //RESULT set to 'X' for any other SELECT value(used for future functional units)
        endcase
    end

    assign ZERO = ~|RESULT;        //assigning ZERO with the result to identify if its a branch/jump signal
                                    //if ZERO = 1 and BRANCHENABLE = 1 , new PC is selected from PCMUX_SEL for beq instruction
                                    //if  ZERO = 0 and BRANCH_NOTEQUAL = 1, new PC is selected from PCMUX_SEL for bne instruction

endmodule
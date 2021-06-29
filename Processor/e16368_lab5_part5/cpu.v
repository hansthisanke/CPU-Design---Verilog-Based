//cpu module
module cpu(PC,INSTRUCTION,CLK,RESET);

input CLK,RESET;
input [31:0] INSTRUCTION;     //to get the 32 bit instruction from testbench
output reg [31:0] PC;         //program counter

//for register module
wire [2:0] WRITEREG, READREG1, READREG2;    //to get addresses of each register 
wire [7:0] REGOUT1, REGOUT2;                //to get output data from the register

//2's Compliment
wire [7:0] inv_REGOUT2;         //stores the two's compliment value of REGOUT2
wire [7:0] mux_twosOUT;         //to get output from the twos compliment mux 

//immediate value
wire [7:0] mux_immedOUT;        //to get output from the immediate value select mux

//for control_unit module
wire [2:0] ALUOP;
wire WRITEENABLE,TWOSCOMPMUX_SEL,IMMEDMUX_SEL,BRANCHENABLE,JUMPENABLE,BRANCH_NOTEQUAL;      //control signals

//for alu to get the result data and ZERO output
wire [7:0] ALURESULT;
wire ZERO;                    

//for branch & jump
wire [31:0] new_PC;           //to get the manipulated PC value from branch or jump
wire [31:0] EXTENDED_VAL;      // to store extended value from 8 bit to 32 bit with a two bit shift
wire PCMUX_SEL;                //mux selector for which PC to use next (new_PC or PC+4)

//to get instructions seperated into 8 bits each
wire [7:0] OPCODE,DESTINATION,IMMEDIATE_VAL;

//seperating the 32 bit instruction 
assign  OPCODE = INSTRUCTION[31:24];
assign  DESTINATION = INSTRUCTION[23:16];       //contain the destination register address or jump/branch offset
assign  IMMEDIATE_VAL = INSTRUCTION[7:0];   //get the immediate value for loadi and shifting 

//getting the register numbers to read and write from each 32bit instructions 
assign  WRITEREG = INSTRUCTION[18:16];  //3 bits each
assign  READREG1 = INSTRUCTION[10:8];
assign  READREG2 = INSTRUCTION[2:0];

//instantiate the control_unit module
control_unit mycontrol(OPCODE,ALUOP,WRITEENABLE,TWOSCOMPMUX_SEL,IMMEDMUX_SEL,BRANCHENABLE,JUMPENABLE,BRANCH_NOTEQUAL);

//instantiate sign_extend_shift module 
sign_extend_shift mysignextend(DESTINATION,ALUOP,EXTENDED_VAL);

//instantiate the reg_file module
reg_file myregfile(ALURESULT, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET);

//get the two's compliment of each REGOUT2 value
assign inv_REGOUT2 = ~REGOUT2+1;

//instantiate the mux_twoscomp module
mux_twoscomp mymuxtwos(REGOUT2,inv_REGOUT2,TWOSCOMPMUX_SEL,mux_twosOUT);

//instantiate the mux_immediate module
mux_immediate mymuximmediate(IMMEDIATE_VAL,mux_twosOUT,IMMEDMUX_SEL,mux_immedOUT);

//instantiate the alu module
alu myalu(REGOUT1,mux_immedOUT,ALURESULT,ALUOP,ZERO);

//instantiate the pc_adder module
pc_adder mypc(EXTENDED_VAL,PC,new_PC);

//output the mux signal according to control signals and ZERO
assign PCMUX_SEL = JUMPENABLE | (BRANCHENABLE & ZERO) | (BRANCH_NOTEQUAL & ~ZERO);

//for updating the program counter with a #1 time delay in a positive clock edge
always @(posedge CLK)
begin
  if (RESET==0) begin
    #1; //delay
    if (PCMUX_SEL) begin       
      PC = new_PC;                      //manipulate PC only if its a branch or jump instruction
    end
    else begin
      PC = PC+4;       //update program counter to fetch next instruction
    end
  end
end

//when reset is active make pc=-4 with a resetting delay of #1
always @(RESET)
begin
  if(RESET)begin
    #1; //PC resetting delay
    PC = -4;
  end
end

endmodule
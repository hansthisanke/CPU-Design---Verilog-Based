`timescale 1ns/100ps
module control_unit(INSTRUCTION,ALUOP,WRITEENABLE,TWOSCOMPMUX_SEL,IMMEDMUX_SEL,BRANCHENABLE,JUMPENABLE,WRITEMUX_SEL,WRITE,READ);
  input [31:0] INSTRUCTION;
  wire [7:0] OPCODE;     //to decide the ALUOP code
  output reg [2:0] ALUOP;     //to select each operation add,sub,loadi,and...
  output reg WRITEENABLE,TWOSCOMPMUX_SEL,IMMEDMUX_SEL,BRANCHENABLE,JUMPENABLE,WRITEMUX_SEL,WRITE,READ;    //control signals

  assign  OPCODE = INSTRUCTION[31:24];

  //decoding the opcode 
  always @(INSTRUCTION)
  begin
    WRITE = 1'b0;
    READ = 1'b0;
    IMMEDMUX_SEL = 1'b0;
    WRITEENABLE = 1'b1;     //enables write to register signal
    #1;                    //delay for decoding and creating control signals 
    TWOSCOMPMUX_SEL = 1'b0; 
    BRANCHENABLE = 1'b0;
    JUMPENABLE = 1'b0;
    WRITEMUX_SEL = 1'b0;

    if(OPCODE == 8'b00000000)         //for loadi instruction
    begin
      ALUOP = 3'b000;
      IMMEDMUX_SEL = 1'b1;                    //enables mux for immediate value select
    end
    else if (OPCODE == 8'b00000001) begin     //for mov instruction
      ALUOP = 3'b000;
    end
    else if (OPCODE == 8'b00000010) begin     //for add instruction
      ALUOP = 3'b001;
    end
    else if (OPCODE == 8'b00000011) begin     //for sub instruction
      ALUOP = 3'b001;
      TWOSCOMPMUX_SEL = 1'b1;                 //enables 2's compliment select mux for sub instructions
    end
    else if (OPCODE == 8'b00000100) begin     //for and instruction
      ALUOP = 3'b010;
    end
    else if (OPCODE == 8'b00000101) begin     //for or instruction
      ALUOP = 3'b011;
    end
    else if (OPCODE == 8'b00000110) begin     //for jump instruction
      ALUOP = 3'b100;  
      JUMPENABLE = 1'b1;                       //enabled to send jump signal to manipulate PC                 
      WRITEENABLE = 1'b0;
    end
    else if (OPCODE == 8'b00000111) begin     //for beq instruction
      ALUOP = 3'b001;                         //used same aluop as add/sub so that the register values difference can be used to calculate ZERO. 
      TWOSCOMPMUX_SEL = 1'b1;                 //enabled to get substract result from two register values
      BRANCHENABLE = 1'b1;                    //enabled to send branch equal signal to manipulate PC
      WRITEENABLE = 1'b0;
    end
    else if (OPCODE == 8'b00001000) begin     //for lwd instruction
      //ALUOP = 3'b101;
      ALUOP = 3'b000;
      WRITEMUX_SEL = 1'b1;                    //enable the write select mux to sent the readdata to the register file for storing
      READ = 1'b1;                            //read signal enabled
    end
    else if (OPCODE == 8'b00001001) begin     //for lwi instruction
      ALUOP = 3'b000;
      WRITEMUX_SEL = 1'b1;                    //enable the write select mux to sent the readdata to the register file for storing
      READ = 1'b1;                            //read signal enabled
      IMMEDMUX_SEL = 1'b1;                    //enables mux for immediate value select
    end
    else if (OPCODE == 8'b00001010) begin     //for swd instruction
      ALUOP = 3'b000;
      WRITEENABLE = 1'b0;                     //writeenable set to zero because storing to the data memory not the register file
      WRITE = 1'b1;                           //write signal enabled
    end
    else if (OPCODE == 8'b00001011) begin     //for swi instruction
      ALUOP = 3'b000;
      WRITEENABLE = 1'b0;                     //writeenable set to zero because storing to the data memory not the register file
      WRITE = 1'b1;                           //write signal enabled
      IMMEDMUX_SEL = 1'b1;                    //enables mux for immediate value select
    end 
    else
    begin
      ALUOP = 3'bxxx;         //default for not yet used ALUOP values
    end
  end

endmodule

module control_unit(OPCODE,ALUOP,WRITEENABLE,TWOSCOMPMUX_SEL,IMMEDMUX_SEL,BRANCHENABLE,JUMPENABLE);

  input [7:0] OPCODE;     //to decide the ALUOP code
  output reg [2:0] ALUOP;     //to select each operation add,sub,loadi,and...
  output reg WRITEENABLE,TWOSCOMPMUX_SEL,IMMEDMUX_SEL,BRANCHENABLE,JUMPENABLE;    //control signals

  //decoding the opcode 
  always @(*)
  begin
    #1;                     //delay for decoding and creating control signals
    WRITEENABLE = 1'b1;     //enables write to register signal
    TWOSCOMPMUX_SEL = 1'b0; 
    IMMEDMUX_SEL = 1'b0;
    BRANCHENABLE = 1'b0;
    JUMPENABLE = 1'b0;

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
      BRANCHENABLE = 1'b1;                    //enabled to send jump/branch signal to manipulate PC
      WRITEENABLE = 1'b0;
    end
    else
    begin
      ALUOP = 3'b1xx;         //default for not yet used ALUOP values
    end
  end

endmodule
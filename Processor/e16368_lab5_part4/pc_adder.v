module pc_adder(EXTENDED_VAL,PC,new_PC);

    input [31:0] EXTENDED_VAL;
    input [31:0] PC;
    output [31:0] new_PC;               //output the manipulated pc value

    assign #2 new_PC = EXTENDED_VAL + PC + 4;           //assigning the new PC value by adding the extended value

endmodule
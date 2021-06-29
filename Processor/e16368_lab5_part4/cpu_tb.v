//cpu testbench
module cpu_tb;

reg CLK,RESET;
wire [31:0] PC;         //program counter
wire [31:0] INSTRUCTION;     //to store instruction fetched from the instruction memory array

//initialize an array of registers to use as instruction memory 
reg [7:0] inst_memory [0:1023];

//executes when the PC updates
//fetching the 32 bit instruction with a #2 time delay
assign #2 INSTRUCTION = {inst_memory[PC],inst_memory[PC+1],inst_memory[PC+2],inst_memory[PC+3]};  

//instruction memory array
initial begin
  {inst_memory[0],inst_memory[1],inst_memory[2],inst_memory[3]} = 32'b00000000000000010000000000001100;                 // loadi 1 0x0C
  {inst_memory[4],inst_memory[5],inst_memory[6],inst_memory[7]} = 32'b00000000000000100000000000000100;                 // loadi 2 0x04
  {inst_memory[8],inst_memory[9],inst_memory[10],inst_memory[11]} = 32'b00000010000000110000000100000010;               // add 3 1 2
  {inst_memory[12],inst_memory[13],inst_memory[14],inst_memory[15]} = 32'b00000000000001000000000011110111;             // loadi 4 0xF7
  {inst_memory[16],inst_memory[17],inst_memory[18],inst_memory[19]} = 32'b00000110000000100000000000000000;             // j 0x02
  {inst_memory[20],inst_memory[21],inst_memory[22],inst_memory[23]} = 32'b00000100000001010000000100000100;             // and 5 1 4    
  {inst_memory[24],inst_memory[25],inst_memory[26],inst_memory[27]} = 32'b00000011000000010000001100000100;             // sub 1 3 4
  {inst_memory[28],inst_memory[29],inst_memory[30],inst_memory[31]} = 32'b00000001000000100000000000000100;             // mov 2 4
  {inst_memory[32],inst_memory[33],inst_memory[34],inst_memory[35]} = 32'b00000101000001100000000100000101;             // or 6 1 5
  {inst_memory[36],inst_memory[37],inst_memory[38],inst_memory[39]} = 32'b00000111111110110000000100000110;             // beg 0xFB 1 6
end

//instantiate the cpu module
cpu mycpu(PC,INSTRUCTION,CLK,RESET);

initial
begin
// generate files needed to plot the waveform using GTKWave
    $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, cpu_tb);
    
//start with
  CLK = 1'b1;
  RESET = 1'b0;
  
  #3
  RESET = 1'b1;         //reset set high to start the program executing

  #5
  RESET = 1'b0;

  #150           //finish after program after a certain time
  $finish;

end

// clock signal generation
  always
    #5 CLK = ~CLK;

endmodule

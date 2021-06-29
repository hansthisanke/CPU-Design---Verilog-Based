//cpu testbench
`timescale 1ns/100ps
module cpu_tb;

reg CLK,RESET;
wire [31:0] PC;         //program counter
wire [31:0] INSTRUCTION;     //to store instruction fetched from the instruction memory array

wire READ,WRITE,BUSYWAIT,MEM_READ,MEM_WRITE,MEM_BUSYWAIT;
wire [7:0] ADDRESS,WRITEDATA,READDATA; 
wire [31:0] MEM_WRITEDATA,MEM_READDATA;
wire [5:0] MEM_ADDRESS;

//initialize an array of registers to use as instruction memory 
reg [7:0] inst_memory [0:1023];

//executes when the PC updates
//fetching the 32 bit instruction with a #2 time delay
assign #2 INSTRUCTION = {inst_memory[PC],inst_memory[PC+1],inst_memory[PC+2],inst_memory[PC+3]};  

//instruction memory array
initial begin
  
  {inst_memory[0],inst_memory[1],inst_memory[2],inst_memory[3]} = 32'b00001001000000000000000000000001;                 // lwi 0 0x01
  {inst_memory[4],inst_memory[5],inst_memory[6],inst_memory[7]} = 32'b00000000000000000000000000001100;                 // loadi 0 0x0C
  {inst_memory[8],inst_memory[9],inst_memory[10],inst_memory[11]} = 32'b00000000000000010000000000001010;               // loadi 1 0x0A
  {inst_memory[12],inst_memory[13],inst_memory[14],inst_memory[15]} = 32'b00000010000000100000000100000000;             // add 2 1 0
  {inst_memory[16],inst_memory[17],inst_memory[18],inst_memory[19]} = 32'b00001010000000000000000100000000;             // swd 1 0
  {inst_memory[20],inst_memory[21],inst_memory[22],inst_memory[23]} = 32'b00000000000000110000000011110111;             // loadi 3 0xF7    
  {inst_memory[24],inst_memory[25],inst_memory[26],inst_memory[27]} = 32'b00001011000000000000001000011001;             // swi 2 0x19
  {inst_memory[28],inst_memory[29],inst_memory[30],inst_memory[31]} = 32'b00000011000001000000000100000010;             // sub 4 1 2
  {inst_memory[32],inst_memory[33],inst_memory[34],inst_memory[35]} = 32'b00001000000001010000000000000000;             // lwd 5 0
  {inst_memory[36],inst_memory[37],inst_memory[38],inst_memory[39]} = 32'b00001000000001100000000000000001;             // lwd 6 1
  {inst_memory[40],inst_memory[41],inst_memory[42],inst_memory[43]} = 32'b00001011000000000000010000111000;             // swi 4 0x38
  
  
  /*
  {inst_memory[0],inst_memory[1],inst_memory[2],inst_memory[3]} = 32'b00000000000000010000000000000100;                 // loadi 1 0x04
  {inst_memory[4],inst_memory[5],inst_memory[6],inst_memory[7]} = 32'b00000000000000100000000000000101;                 // loadi 2 0x05
  {inst_memory[8],inst_memory[9],inst_memory[10],inst_memory[11]} = 32'b00001011000000000000001000000001;               // swi 2 0x01
  {inst_memory[12],inst_memory[13],inst_memory[14],inst_memory[15]} = 32'b00001011000000000000000100001001;             // swi 1 0x09
  {inst_memory[16],inst_memory[17],inst_memory[18],inst_memory[19]} = 32'b00001001000001000000000000000001;             // lwi 4 0x01
  {inst_memory[20],inst_memory[21],inst_memory[22],inst_memory[23]} = 32'b00001001000001010000000000001001;             // lwi 5 0x09  
  {inst_memory[24],inst_memory[25],inst_memory[26],inst_memory[27]} = 32'b00000010000000000000010100000100;             // add 0 5 4
  {inst_memory[28],inst_memory[29],inst_memory[30],inst_memory[31]} = 32'b00000000000001110000000000000001;             // loadi 7 0x01
  {inst_memory[32],inst_memory[33],inst_memory[34],inst_memory[35]} = 32'b00001000000000110000000000000111;             // lwd 3 7
  {inst_memory[36],inst_memory[37],inst_memory[38],inst_memory[39]} = 32'b00001010000000000000001000000001;             // swd 2 1
  {inst_memory[40],inst_memory[41],inst_memory[42],inst_memory[43]} = 32'b00001011000000000000001100100001;             // swi 3 0x21
  {inst_memory[44],inst_memory[45],inst_memory[46],inst_memory[47]} = 32'b00000010000000110000001100000000;             // add 3 3 0
  {inst_memory[48],inst_memory[49],inst_memory[50],inst_memory[51]} = 32'b00000000000000000000000000000001;             // loadi 0 0x01
  {inst_memory[52],inst_memory[53],inst_memory[54],inst_memory[55]} = 32'b00001000000001010000000000000000;             // lwd 5 0
  {inst_memory[56],inst_memory[57],inst_memory[58],inst_memory[59]} = 32'b00000010000001110000010100000000;             // add 7 5 0 
  */
end

//instantiate the cpu module
cpu mycpu(PC,INSTRUCTION,CLK,RESET,READ,WRITE,ADDRESS,WRITEDATA,READDATA,BUSYWAIT);
 
//instantiate the data module
data_memory mydatamem(CLK,RESET,MEM_READ,MEM_WRITE,MEM_ADDRESS,MEM_WRITEDATA,MEM_READDATA,MEM_BUSYWAIT);

//instantiate the cache module
dcache mydcache(CLK,RESET,READ,WRITE,ADDRESS,WRITEDATA,READDATA,BUSYWAIT,MEM_READ,MEM_WRITE,MEM_ADDRESS,MEM_WRITEDATA,MEM_READDATA,MEM_BUSYWAIT);

//integer i;

initial
begin
// generate files needed to plot the waveform using GTKWave
    $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, cpu_tb);
    
    /*
    for (i = 0 ;i<8 ;i=i+1 ) begin
      $dumpvars(0,mycpu.myregfile.registers[i]);
    end
    */
    
//start with
  CLK = 1'b1;
  RESET = 1'b0;
  
  #2
  RESET = 1'b1;        //reset set high to start the program executing

  #4
  RESET = 1'b0;

  #1500          //finish after program after a certain time
  $finish;

end

// clock signal generation
  always
    #4 CLK = ~CLK;

endmodule

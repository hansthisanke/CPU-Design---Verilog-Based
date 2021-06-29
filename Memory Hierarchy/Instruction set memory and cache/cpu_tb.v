//cpu testbench
`timescale 1ns/100ps
module cpu_tb;

reg CLK,RESET;
wire [31:0] PC;         //program counter
wire [31:0] INSTRUCTION;     //to store instruction fetched from the instruction memory array

wire READ,WRITE,MEM_READ,MEM_WRITE,MEM_BUSYWAIT;
wire [7:0] ADDRESS,WRITEDATA,READDATA; 
wire [31:0] MEM_WRITEDATA,MEM_READDATA;
wire [5:0] MEM_ADDRESS;

//for instruction memory
wire INSTRUCT_READ,INSTRUCT_BUSYWAIT;
wire [5:0] INSTRUCT_ADDRESS;
wire [127:0] INSTRUCT_READDATA;

//create wires to send and recieve busywait signals from dcache and instructcache
wire BUSYWAIT,INSTCACHE_BUSYWAIT,DCACHE_BUSYWAIT;

//assign busywait signal according to generated cache busywait signals and send to cpu to stall
assign BUSYWAIT = (INSTCACHE_BUSYWAIT || DCACHE_BUSYWAIT);

/*
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
  

end
*/

//instantiate the instruction module
instruct_memory myinstruct(CLK,INSTRUCT_READ,INSTRUCT_ADDRESS,INSTRUCT_READDATA,INSTRUCT_BUSYWAIT);

//instantiate the instruction cache module
instructcache myinscache(CLK,RESET,PC[10:0],INSTCACHE_BUSYWAIT,INSTRUCT_READ,INSTRUCT_ADDRESS,INSTRUCT_READDATA,INSTRUCT_BUSYWAIT,INSTRUCTION);

//instantiate the cpu module
cpu mycpu(PC,INSTRUCTION,CLK,RESET,READ,WRITE,ADDRESS,WRITEDATA,READDATA,BUSYWAIT);
 
//instantiate the data module
data_memory mydatamem(CLK,RESET,MEM_READ,MEM_WRITE,MEM_ADDRESS,MEM_WRITEDATA,MEM_READDATA,MEM_BUSYWAIT);

//instantiate the cache module
dcache mydcache(CLK,RESET,READ,WRITE,ADDRESS,WRITEDATA,READDATA,DCACHE_BUSYWAIT,MEM_READ,MEM_WRITE,MEM_ADDRESS,MEM_WRITEDATA,MEM_READDATA,MEM_BUSYWAIT);

integer i;

initial
begin
// generate files needed to plot the waveform using GTKWave
    $dumpfile("cpu_wavedata.vcd");
		$dumpvars(0, cpu_tb);
    
    //for indicating register values in the gtkwave
    for (i = 0 ;i<8 ;i=i+1 ) begin
      $dumpvars(0,mycpu.myregfile.registers[i]);
    end
    
    
//start with
  CLK = 1'b1;
  RESET = 1'b0;
  
  #2
  RESET = 1'b1;        //reset set high to start the program executing

  #4
  RESET = 1'b0;

  #4000          //finish after program after a certain time
  $finish;

end

// clock signal generation
  always
    #4 CLK = ~CLK;

endmodule

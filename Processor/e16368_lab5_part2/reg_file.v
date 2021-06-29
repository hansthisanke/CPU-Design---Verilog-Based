//testbench
/*
module reg_file_tb;
    
    reg [7:0] WRITEDATA;
    reg [2:0] WRITEREG, READREG1, READREG2;
    reg CLK, RESET, WRITEENABLE; 
    wire [7:0] REGOUT1, REGOUT2;
    
    reg_file myregfile(WRITEDATA, REGOUT1, REGOUT2, WRITEREG, READREG1, READREG2, WRITEENABLE, CLK, RESET);
       
    initial
    begin
        CLK = 1'b1;
        
        // generate files needed to plot the waveform using GTKWave
        $dumpfile("reg_file_wavedata.vcd");
		$dumpvars(0, reg_file_tb);
        
        // assign values with time to input signals to see output 
        RESET = 1'b0;
        WRITEENABLE = 1'b0;
        
        #1
        RESET = 1'b1;
        READREG1 = 3'd1;
        READREG2 = 3'd5;
        
        #6
        RESET = 1'b0;
        
        #8
        WRITEREG = 3'd1;
        WRITEDATA = 8'd30;
        WRITEENABLE = 1'b1;
        
        #10
        WRITEREG = 3'd6;
        WRITEDATA = 8'd45;
        
        #7
        WRITEENABLE = 1'b0;
        READREG2 = 3'd6;
        
        #8
        WRITEREG = 3'd2;
        WRITEDATA = 8'd12;
        WRITEENABLE = 1'b1;
        
        #2
        READREG1 = 3'd2;
        
        #6
        WRITEENABLE = 1'b0;
        
        #6
        WRITEREG = 3'd6;
        WRITEDATA = 8'd90;
        WRITEENABLE = 1'b1;
        
        #10
        WRITEDATA = 8'd100;
        //WRITEENABLE = 1'b1;
        
        #10
        WRITEENABLE = 1'b0;
        
        #8
        READREG2 = 3'd5;
        
        #10
        $finish;
    end
    
    // clock signal generation
    always
        #5 CLK = ~CLK;
        

endmodule
*/

//reg_file
module reg_file(IN,OUT1,OUT2,INADDRESS,OUT1ADDRESS,OUT2ADDRESS,WRITE,CLK,RESET);
 
  input CLK,RESET;         //for synchronization
  
  //Write Port declaration
  input WRITE;               //control input port for WRITEENABLE control signal 
  input [7:0] IN;            //data input (alu result)
  input [2:0] INADDRESS;     //register number to store data recieved from IN port

  //input port 1 declaration
  input [2:0] OUT1ADDRESS;   //register number to retrieve data
  output [7:0] OUT1;         //data output

  //input port 2 declaration
  input [2:0] OUT2ADDRESS;   //register number to retrieve data
  output [7:0] OUT2;         //data output
  
  //register file storage
  reg [7:0] registers[7:0];       //for 8 , 8-bit values(register0-register7)

  integer i;    //for the loop increment

  always @(RESET)      //execute when reset changes its value
  begin
    if(RESET)begin      //if reset is enabled(true) run the loop
      #2;      //latency for resetting the registers
      for (i=0; i<8; i=i+1) begin    
        registers[i] = 8'b0;         //setting all register data values to zero
      end
    end
  end

  always @(posedge CLK)  //executes for rising edge of clock
  begin    
    if(WRITE)begin         //if write enables(true) store data in register
      #2;   //latency for writing into register
      registers[INADDRESS] <= IN;        //writing data into register
    end 
  end

  //reading data from registers and values loaded onto outputs with a #2 delay
  assign #2 OUT1 =  registers[OUT1ADDRESS];    
  assign #2 OUT2 =  registers[OUT2ADDRESS];  
  

endmodule
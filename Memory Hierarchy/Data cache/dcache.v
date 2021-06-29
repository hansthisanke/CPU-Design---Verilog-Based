`timescale 1ns/100ps
module dcache(clock,reset,read,write,address,writedata,readdata,busywait,mem_read,mem_write,mem_address,mem_writedata,mem_readdata,mem_busywait);
    
    input clock,reset,read,write;
    input [7:0] address,writedata;
    output reg busywait;    //send signal to stall the CPU on a memory read/write instruction
    output [7:0] readdata;      //output the data fetched from memory to store in register
    
    input [31:0] mem_readdata;          //get the new fetched data block from data memory
    input mem_busywait;                 //signal recieved that the data memory is running
    output reg mem_read,mem_write;  
    output reg [5:0] mem_address;
    output reg [31:0] mem_writedata;        //send the dirty data block in cache to  write to the data memory

    reg [31:0] data_cache [0:7];            //cache memory with a 32 byte size

    reg [2:0] tag_array [0:7];              //contain tag for each data block
    reg [7:0] valid_array,dirty_array;         //contain valid and dirty status for each data block
    
    reg [31:0] data;        //to fetch the required data block according to index of current address
    wire valid,dirty;       // to hold status of valid,dirty for in use current data block 
    wire hit;               // to identify a hit or miss
    wire [2:0] index,tag;   //to store extracted tag and index parts from the current address
    wire tagMatch;          //for tag comparison
    
    /*
    Combinational part for indexing, tag comparison for hit deciding, etc.
    ...
    */
    always@ (read,write)
    begin
        if(read || write)
            busywait = 1;       //if read or write enables stall the cpu to fetch from data memory 
        else
            busywait = 0;
    end
 
    assign index = address[4:2];        //index part of current address
    
    always@ (*)
    begin
        #1
        data = data_cache[address[4:2]];        //32 bit data currently in the data cache, in the index block
    end
    
    //with a latency of #1 extracting from the stored datablock	tag,valid and dirty status    	
    assign #1 tag = tag_array[index];               
    assign #1 valid = valid_array[index];
    assign #1 dirty = dirty_array[index];

    assign #0.9 tagMatch = (tag == address[7:5]) ? 1 : 0;       //check whether tag and current address tag match
    assign hit = valid && tagMatch;                             //if cache block is valid and tag matches its a hit
    
    //read the requested data, according to address offset and send to the CPU for register write
    assign #1 readdata = ((address[1:0] == 2'b00) && read)? data[7:0]:
                         ((address[1:0] == 2'b01) && read)? data[15:8]:
                         ((address[1:0] == 2'b10) && read)? data[23:16]:data[31:24];
    /*
    always@(hit)
    begin  
      if (hit==1 && read == 1) begin                    //if a read hit, according to address offset select data and send to CPU for register write
        case (address[1:0])
            2'b00: readdata = data[7:0];     
            2'b01: readdata = data[15:8];
            2'b10: readdata = data[23:16];
            default: readdata = data[31:24];
        endcase

      end 
    end
    */
    
    
    always@ (posedge clock)
    begin
      if(hit == 1 && write == 1) begin                  //if a write hit, according to the offset store in cache block the recieved writedata  
        #1;                                             //time delay for writing into the cache according to the offset of address
        dirty_array[index] = 1;                         //set dirty to 1 because an update to the cache block only happened(need to write to data memory later)
        case (address[1:0])
            2'b00: data_cache[index][7:0] = writedata;     
            2'b01: data_cache[index][15:8] = writedata;
            2'b10: data_cache[index][23:16] = writedata;
            default: data_cache[index][31:24] = writedata;
        endcase
                             
      end
    end

    integer i;

     //Reset cache blocks 
    always @(posedge reset)
    begin
        for (i=0;i<8; i=i+1)
        begin
            data_cache[i] = 32'dx;      //set to unknown values
            tag_array[i] = 3'dx;        //set to unknown values
            valid_array[i] = 0;
            dirty_array[i] = 0;
        end
    end

    always@ (posedge clock)
    begin
      if (hit) begin            //at posedge clock if its a hit de-assert the busywait so the CPU runs without stalling
          busywait = 0;     
      end
    end
    
    

    /* Cache Controller FSM Start */

    parameter IDLE = 2'b00, MEM_READ = 2'b01, MEM_WRITE = 2'b10, UPDATE_CACHE = 2'b11;
    reg [2:0] state, next_state;

    // combinational next state logic
    always @(*)
    begin
        case (state)
            IDLE:
                if ((read || write) && !dirty && !hit)  
                    next_state = MEM_READ;                      //if its a read/write miss and not a dirty cache block, read the required data block from memory
                else if ((read || write) && dirty && !hit)
                    next_state = MEM_WRITE;                     //if its a read/write miss and a dirty cache block write back the cache data into the data memory
                else
                    next_state = IDLE;
            
            MEM_READ:
                if (!mem_busywait)   
                    next_state = UPDATE_CACHE;          //if data memory done fetching the data block go to update cache state
                else    
                    next_state = MEM_READ;              //stay in mem_read state until mem_busywait de-asserts
            MEM_WRITE:
                if (!mem_busywait)
                    next_state = MEM_READ;              //if write back is completed go to mem_read state and fetch the required data block from memory
                else 
                    next_state = MEM_WRITE;             //stay in mem_write state until mem_busywait de-asserts
            UPDATE_CACHE:
                    next_state = IDLE;                  //when cache update is done go to idle state 
        endcase
    end

    // combinational output logic
    always @(state)
    begin
        case(state)
            IDLE:
            begin                          //state which the fsm is not used or after doing the state transition becomes idle.
                mem_read = 0;
                mem_write = 0;
                mem_address = 5'dx;
                mem_writedata = 32'dx;
                busywait = 0;
            end
         
            MEM_READ: 
            begin
                mem_read = 1;                       //enable memory read signal and send to the data memory to assert mem_busywait signal
                mem_write = 0;
                mem_address = {address[7:2]};       //send the data block address part of the required address to fetch the data block
                mem_writedata = 32'dx;
            end

            MEM_WRITE:
            begin
                mem_read = 0;
                mem_write = 1;                      //enable memory write signal and send to the data memory to assert mem_busywait signal
                mem_address = {tag,address[4:2]};          //send the dirty data block address to store data to the data memory
                mem_writedata = data;               //send the data to be stored in the mem_address
            end

            UPDATE_CACHE:
            begin
              mem_read = 0;                         //disable memory read,write signals
              mem_write = 0;
              mem_address = 5'dx;
              mem_writedata = 32'dx;

              #1          //delay for writing into the cache block
              data_cache[index] = mem_readdata;         //store the newly fetch data from memory to the current cache data block
              tag_array[index] = address[7:5];          //update tag_array according to the address portion of tag in the current data block 
              valid_array[index] = 1;                   //update valid and dirty status of the data cache block
              dirty_array[index] = 0;
              //busywait = 0;
            end

        endcase
    end


    // sequential logic for state transitioning 
    always @(posedge clock, reset)
    begin
        if(reset)
            state = IDLE;               //in a reset stay in the IDLE state
        else
            state = next_state;            //change state to the next state in a posedge clock
    end

    /* Cache Controller FSM End */

endmodule
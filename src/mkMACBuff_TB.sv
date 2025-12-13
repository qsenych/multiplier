`timescale 1ns / 1ps
`define CLK_DELAY #2;
`define HALF_CLK_DELAY #1;
`define HALF_CLK_DELAY_MINUS_EDGE_GAP #0.9;
`define EDGE_GAP #0.1;
`define N 33

module mkMACBuff_TB;

localparam NUM_ITERS = 8;
localparam ADDR_WIDTH = 6;
localparam ADDR_DEPTH = 64;
reg CLK;
reg RESET;
wire RST_N;
assign RST_N = ~RESET;

// CLK
always begin `HALF_CLK_DELAY; CLK = ~CLK; end

// ---------------------------------------------------------------------------------

// define nets 
logic unsigned EN_mac, EN_blockRead;
logic unsigned [15:0] mac_vectA_0, mac_vectA_1, mac_vectA_2, mac_vectA_3;
logic unsigned [15:0] mac_vectB_0, mac_vectB_1, mac_vectB_2, mac_vectB_3;
logic unsigned RDY_mac, EN_readMem, EN_writeMem, VALID_memVal, RDY_blockRead;
logic unsigned [`N:0] writeMem_val, readMem_val, memVal_data;
logic unsigned [5:0] writeMem_addr, readMem_addr;

logic unsigned [`N:0] stored_val[100];


// instantiation
mkMACBuff mkMACBuff(
    .CLK(CLK), .RST_N(RST_N),
    
    .EN_mac(EN_mac), .RDY_mac(RDY_mac),
    .mac_vectA_0(mac_vectA_0), .mac_vectB_0(mac_vectB_0),
    .mac_vectA_1(mac_vectA_1), .mac_vectB_1(mac_vectB_1),
    .mac_vectA_2(mac_vectA_2), .mac_vectB_2(mac_vectB_2),
    .mac_vectA_3(mac_vectA_3), .mac_vectB_3(mac_vectB_3),
    
    .EN_writeMem(EN_writeMem), .writeMem_addr(writeMem_addr), .writeMem_val(writeMem_val),
    
    .EN_blockRead(EN_blockRead), .RDY_blockRead(RDY_blockRead),
    
    .EN_readMem(EN_readMem), .readMem_addr(readMem_addr), .readMem_val(readMem_val),
    .VALID_memVal(VALID_memVal), .memVal_data(memVal_data)
    );
    
// memory wrapper
memory_wrapper_2port #( .DEPTH(64), .LOGDEPTH(6), .WIDTH(34)) 
            memory_2port ( 
                .clkA(CLK), .aA(readMem_addr), .cenA(~EN_readMem), .q(readMem_val),
                .clkB(CLK), .aB(writeMem_addr), .cenB(~EN_writeMem), .d(writeMem_val)
                    );

// ---------------------------------------------------------------------------------

//Initialization
task TASK_init;
begin
    CLK = 1'b0;
    RESET = 1'b1;

    EN_mac = 0;
    EN_blockRead = 0;
    mac_vectA_0 = 0; 
    mac_vectA_1 = 0; 
    mac_vectA_2 = 0; 
    mac_vectA_3 = 0;
    mac_vectB_0 = 0; 
    mac_vectB_1 = 0; 
    mac_vectB_2 = 0; 
    mac_vectB_3 = 0;
end
endtask

// reset
task TASK_reset;
begin
    RESET = 1'b0;
    @(posedge CLK); #0.2;
    RESET = 1'b1;
    @(posedge CLK); #0.2;
    @(posedge CLK); #0.2;
    RESET = 1'b0;
end
endtask

// testing DUT
task TASK_DUT;
    // define data structures to use in the task here
logic expMACBuff [ADDR_DEPTH -1:0];
logic expMACOut;
integer j;
begin
    wait(RDY_mac === 1'b1);
    @(posedge CLK); #0.2;

    for (j = 0; j < NUM_ITERS; j = j + 1) begin
        $display("========== Starting iter %d =========", j);
	// if (j % 2 == 0) memfill(j + 1);
        memfill_rand();

	readmem();
    end
end
endtask


//Work on all the tasks from the beginning.
initial begin
    TASK_init;
    TASK_reset;
    TASK_DUT;
    
    $stop;
end

// Helper tasks
task automatic memfill (input int unsigned k); 
    int unsigned i = 0;
    int unsigned i0 = 0;
    int unsigned i1 = 0;
    int unsigned i2 = 0;
    int unsigned i3 = 0;
    int unsigned j0 = 0;
    int unsigned j1 = 0;
    int unsigned j2 = 0;
    int unsigned j3 = 0;
    $display("memfill");
    @(posedge CLK); #0.2;
    EN_mac = 1'b1;

    while (RDY_mac) begin
        i0 = 1*k*i;
        i1 = 3*k*i;
        i2 = 5*k*i;
        i3 = 7*k*i;
        j0 = 2*k*i;
        j1 = 4*k*i;
        j2 = 6*k*i;
        j3 = 8*k*i;

        if (i >= 64) EN_mac = 1'b0;
        mac_vectA_0 = i0; 
        mac_vectA_1 = i1; 
        mac_vectA_2 = i2; 
        mac_vectA_3 = i3;
        mac_vectB_0 = j0; 
        mac_vectB_1 = j1; 
        mac_vectB_2 = j2; 
        mac_vectB_3 = j3; 
        stored_val[i] = i0*j0 + i1*j1 + i2*j2 + i3*j3;
    	@(posedge CLK); #0.2;
        i++;
    end
endtask



task automatic memfill_rand (); 
    int unsigned i = 0;
    int unsigned i0 = 0;
    int unsigned i1 = 0;
    int unsigned i2 = 0;
    int unsigned i3 = 0;
    int unsigned j0 = 0;
    int unsigned j1 = 0;
    int unsigned j2 = 0;
    int unsigned j3 = 0;
    $display("memfill_rand");
    @(posedge CLK); #0.2;
    EN_mac = 1'b1;

    while (RDY_mac) begin
        i0 = $urandom & 16'hFFFF;
        i1 = $urandom & 16'hFFFF;
        i2 = $urandom & 16'hFFFF;
        i3 = $urandom & 16'hFFFF;
        j0 = $urandom & 16'hFFFF;
        j1 = $urandom & 16'hFFFF;
        j2 = $urandom & 16'hFFFF;
        j3 = $urandom & 16'hFFFF;

        if (i >= 64) EN_mac = 1'b0;
        mac_vectA_0 = i0; 
        mac_vectA_1 = i1; 
        mac_vectA_2 = i2; 
        mac_vectA_3 = i3;
        mac_vectB_0 = j0; 
        mac_vectB_1 = j1; 
        mac_vectB_2 = j2; 
        mac_vectB_3 = j3; 
        stored_val[i] = (i0*j0 + i1*j1 + i2*j2 + i3*j3);
        @(posedge CLK); #0.2;
        i++;

        if (i > 64) break;
    end
    EN_mac = 1'b0;
endtask


task automatic readmem(); 
    wait(RDY_blockRead);
    @(posedge CLK); #0.2;

    EN_blockRead = 1'b1;

    wait(VALID_memVal == 1'b1);
    $display("readmem");

    EN_blockRead = 1'b0;
    for (int i = 0; i <= 64; i++) begin
        
        if (i < 64) begin
            assert(readMem_val === stored_val[i]) 
            else $error("readMem_val = %d, stored_val[%d] = %d", 
                        readMem_val, i, stored_val[i]);
        end
	@(posedge CLK); #0.2;
    end
endtask

endmodule: mkMACBuff_TB

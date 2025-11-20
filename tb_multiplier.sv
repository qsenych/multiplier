`timescale 1ns / 1ps

module tb_multiplier;
    logic CLK, EN_mult, EN_blockRead;
    logic [15:0] mult_input0, mult_input1;
    logic RDY_mult, EN_readMem, EN_writeMem, VALID_memVal;
    logic [31:0] writeMem_val, readMem_val, memVal_data;
    logic [5:0] writeMem_addr, readMem_addr;

    int stored_val[100];

    localparam NUM_ITERS = 10;

    multiplier mult (
        .CLK(CLK), 
        .EN_mult(EN_mult), 
        .EN_blockRead(EN_blockRead),
        .mult_input0(mult_input0), 
        .mult_input1(mult_input1), 
        .readMem_val(readMem_val),
        .RDY_mult(RDY_mult), 
        .EN_readMem(EN_readMem), 
        .EN_writeMem(EN_writeMem),
        .VALID_memVal(VALID_memVal),
        .writeMem_val(writeMem_val),
        .memVal_data(memVal_data),
        .writeMem_addr(writeMem_addr),
        .readMem_addr(readMem_addr)
    );

    memory_wrapper_2port #(.WIDTH(32)) mem (
        .clkA(CLK), .aA(readMem_addr), .cenA(~EN_readMem), .q(readMem_val),
        .clkB(CLK), .aB(writeMem_addr), .cenB(~EN_writeMem), .d(writeMem_val)
        ); 

    always begin #1.25 CLK = ~CLK; end //400MHz clock, set to 0.625 for 800MHz
    initial begin
        CLK = 0;
        EN_mult = 0;
        EN_blockRead = 0;
        mult_input0 = 0;
        mult_input1 = 0;

        wait(RDY_mult === 1'b1); #1.25;

        for (int j = 1; j < NUM_ITERS; j++) begin
            memfill(j*2);
            readmem();
        end
        $stop;
    end

    task automatic memfill (input int k); 
        int i = 0;
        EN_mult = 1'b1;
        mult_input0 = 16'd6;
        mult_input1 = 16'd4;
        stored_val[0] = mult_input0 * mult_input1;

        while (RDY_mult) begin
            #2.5;
            if (i >= 63) EN_mult = 1'b0;
            mult_input0 = i;
            mult_input1 = k;
            stored_val[i+1] = mult_input0*mult_input1;
            i++;
        end
    endtask


    task automatic readmem(); 
        EN_blockRead = 1'b1;

        wait(VALID_memVal == 1'b1);

        EN_blockRead = 1'b0;
        for (int i = 0; i < 71; i++) begin
            #2.5;
            if (i < 64) begin
                assert(readMem_val == stored_val[i]) 
                else $error("readMem_val = %d, stored_val[%d] = %d", 
                            readMem_val, i, stored_val[i]);
            end
        end
    endtask

endmodule: tb_multiplier

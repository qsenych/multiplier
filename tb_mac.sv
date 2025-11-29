`timescale 1ns / 1ps

module tb_mac;
    logic unsigned CLK, EN_mac, EN_blockRead, RST_N;
    logic unsigned [15:0] mac_vectA_0, mac_vectA_1, mac_vectA_2, mac_vectA_3;
    logic unsigned [15:0] mac_vectB_0, mac_vectB_1, mac_vectB_2, mac_vectB_3;
    logic unsigned RDY_mac, EN_readMem, EN_writeMem, VALID_memVal, RDY_blockRead;
    logic unsigned [31:0] writeMem_val, readMem_val, memVal_data;
    logic unsigned [5:0] writeMem_addr, readMem_addr;

    int stored_val[100];

    localparam NUM_ITERS = 4;
	localparam CLK_PERIOD = 2;//500 MHz clock
	localparam HALF_CLK_PERIOD = CLK_PERIOD / 2;//400MHz clock, set to 1.25 for 800MHz

    mac dut(
        .CLK(CLK), 
		.RST_N(RST_N),
        .EN_mac(EN_mac), 
        .EN_blockRead(EN_blockRead),
        .mac_vectA_0(mac_vectA_0),
        .mac_vectA_1(mac_vectA_1),
        .mac_vectA_2(mac_vectA_2),
        .mac_vectA_3(mac_vectA_3),
        .mac_vectB_0(mac_vectB_0),
        .mac_vectB_1(mac_vectB_1),
        .mac_vectB_2(mac_vectB_2),
        .mac_vectB_3(mac_vectB_3),
        .readMem_val(readMem_val),
        .RDY_mac(RDY_mac), 
        .RDY_blockRead(RDY_blockRead), 
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

    always begin #HALF_CLK_PERIOD CLK = ~CLK; end 
    initial begin
        CLK = 0;
		RST_N = 0;
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

		#CLK_PERIOD;
		#CLK_PERIOD;
		#CLK_PERIOD;
		RST_N = 1;
		#CLK_PERIOD;
		#CLK_PERIOD;

        wait(RDY_mac === 1'b1); #HALF_CLK_PERIOD;

        for (int j = 1; j < NUM_ITERS; j++) begin
			$display("========== Starting iter %d =========", j);
            memfill_rand();
            readmem();
        end
        $stop;
    end

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
            #CLK_PERIOD;
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
		$display("memfill");
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
            stored_val[i] = (i0*j0 + i1*j1 + i2*j2 + i3*j3) & 32'hFFFFFFFF;
            #CLK_PERIOD;
            i++;
        end
    endtask


    task automatic readmem(); 
        wait(RDY_blockRead);

        EN_blockRead = 1'b1;

        wait(VALID_memVal == 1'b1);
		$display("readmem");

        EN_blockRead = 1'b0;
        for (int i = 0; i < 71; i++) begin
            #CLK_PERIOD;
            if (i < 64) begin
                assert(readMem_val == stored_val[i]) 
                else $error("readMem_val = %d, stored_val[%d] = %d", 
                            readMem_val, i, stored_val[i]);
            end
        end
    endtask

endmodule: tb_mac

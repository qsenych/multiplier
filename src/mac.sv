module mac#(parameter N = 32) (
    input logic CLK, EN_mac, EN_blockRead, RST_N,
    input logic [15:0] mac_vectA_0, mac_vectA_1, mac_vectA_2, mac_vectA_3,
    input logic [15:0] mac_vectB_0, mac_vectB_1, mac_vectB_2, mac_vectB_3,
    input logic [N - 1:0] readMem_val,
    output logic RDY_mac, EN_readMem, EN_writeMem, VALID_memVal, RDY_blockRead,
    output logic [N - 1:0] writeMem_val, memVal_data,
    output logic [5:0] writeMem_addr, readMem_addr
    );

    typedef enum logic [1:0]{
        INIT,
        IDLE_WRITE,
        FULL,
        READ
    } state_t;

    state_t curr_state, next_state;

    logic [5:0] write_addr_reg, read_addr_reg;

    logic mem_full_flag;

	logic [7:0] p0r0m0, p0r1m0, p0r2m0, p0r3m0, p0r4m0, p0r5m0, p0r6m0, p0r7m0;
	logic [7:0] p0r8m0, p0r9m0, p0r10m0, p0r11m0, p0r12m0, p0r13m0, p0r14m0, p0r15m0;
	logic [19:0] p1sum0m0, p1sum1m0, p1sum2m0, p1sum3m0;
	logic [31:0] p2sum0m0, p2sum1m0;
	logic [31:0] p3outm0;
	
	logic [7:0] p0r0m1, p0r1m1, p0r2m1, p0r3m1, p0r4m1, p0r5m1, p0r6m1, p0r7m1;
	logic [7:0] p0r8m1, p0r9m1, p0r10m1, p0r11m1, p0r12m1, p0r13m1, p0r14m1, p0r15m1;
	logic [19:0] p1sum0m1, p1sum1m1, p1sum2m1, p1sum3m1;
	logic [31:0] p2sum0m1, p2sum1m1;
	logic [31:0] p3outm1;
	
	logic [7:0] p0r0m2, p0r1m2, p0r2m2, p0r3m2, p0r4m2, p0r5m2, p0r6m2, p0r7m2;
	logic [7:0] p0r8m2, p0r9m2, p0r10m2, p0r11m2, p0r12m2, p0r13m2, p0r14m2, p0r15m2;
	logic [19:0] p1sum0m2, p1sum1m2, p1sum2m2, p1sum3m2;
	logic [31:0] p2sum0m2, p2sum1m2;
	logic [31:0] p3outm2;
	
	logic [7:0] p0r0m3, p0r1m3, p0r2m3, p0r3m3, p0r4m3, p0r5m3, p0r6m3, p0r7m3;
	logic [7:0] p0r8m3, p0r9m3, p0r10m3, p0r11m3, p0r12m3, p0r13m3, p0r14m3, p0r15m3;
	logic [19:0] p1sum0m3, p1sum1m3, p1sum2m3, p1sum3m3;
	logic [31:0] p2sum0m3, p2sum1m3;
	logic [31:0] p3outm3;


	logic [33:0] p4val_m0m1, p4val_m2m3;
	logic [33:0] p5out;

    logic pipe0_en, pipe1_en, pipe2_en, pipe3_en, pipe4_en, pipe5_en;

    logic valid_read_reg;

    assign memVal_data = readMem_val;

    // writeMem_addr starts at 0, increments by 1 every multiplication
    // readMem_addr starts at 0, increments by 1 once reading starts
    //      Can't change once startec
    always_ff @(posedge CLK) begin
		if (!RST_N) begin
			curr_state <= INIT;

			pipe0_en <= 0;
			pipe1_en <= 0;
			pipe2_en <= 0;
			pipe3_en <= 0;
			pipe4_en <= 0;
			pipe5_en <= 0;

			mem_full_flag <= 1'b0;
			write_addr_reg <= 6'b0;
			read_addr_reg <= 6'b0;
		end else begin
			curr_state <= next_state;
	
			pipe0_en <= EN_mac;
			pipe1_en <= pipe0_en;
			pipe2_en <= pipe1_en;
			pipe3_en <= pipe2_en;
			pipe4_en <= pipe3_en;
			pipe5_en <= pipe4_en;

			// =============== mult 0 ============= //
			p0r0m0 <= mac_vectA_0[3:0]  * mac_vectB_0[3:0];
			p0r1m0 <= mac_vectA_0[3:0]  * mac_vectB_0[7:4];
			p0r2m0 <= mac_vectA_0[3:0]  * mac_vectB_0[11:8];
			p0r3m0 <= mac_vectA_0[3:0]  * mac_vectB_0[15:12];
			p0r4m0 <= mac_vectA_0[7:4]  * mac_vectB_0[3:0];
			p0r5m0 <= mac_vectA_0[7:4]  * mac_vectB_0[7:4];
			p0r6m0 <= mac_vectA_0[7:4]  * mac_vectB_0[11:8];
			p0r7m0 <= mac_vectA_0[7:4]  * mac_vectB_0[15:12];
			p0r8m0 <= mac_vectA_0[11:8]  * mac_vectB_0[3:0];
			p0r9m0 <= mac_vectA_0[11:8]  * mac_vectB_0[7:4];
			p0r10m0 <= mac_vectA_0[11:8]  * mac_vectB_0[11:8];
			p0r11m0 <= mac_vectA_0[11:8]  * mac_vectB_0[15:12];
			p0r12m0 <= mac_vectA_0[15:12]  * mac_vectB_0[3:0];
			p0r13m0 <= mac_vectA_0[15:12]  * mac_vectB_0[7:4];
			p0r14m0 <= mac_vectA_0[15:12]  * mac_vectB_0[11:8];
			p0r15m0 <= mac_vectA_0[15:12]  * mac_vectB_0[15:12];
			p1sum0m0 <= {12'b0, p0r0m0} +
					  {8'b0, p0r1m0, 4'b0} +
					  {4'b0, p0r2m0, 8'b0} +
					  {p0r3m0, 12'b0};
			p1sum1m0 <= {12'b0, p0r4m0} +
					  {8'b0, p0r5m0, 4'b0} +
					  {4'b0, p0r6m0, 8'b0} +
					  {p0r7m0, 12'b0};
			p1sum2m0 <= {12'b0, p0r8m0} +
					  {8'b0, p0r9m0, 4'b0} +
					  {4'b0, p0r10m0, 8'b0} +
					  {p0r11m0, 12'b0};
			p1sum3m0 <= {12'b0, p0r12m0} +
					  {8'b0, p0r13m0, 4'b0} +
					  {4'b0, p0r14m0, 8'b0} +
					  {p0r15m0, 12'b0};
			p2sum0m0 <= {8'b0, ({4'b0, p1sum0m0} + {p1sum1m0, 4'b0})};
			p2sum1m0 <= {({4'b0, p1sum2m0} + {p1sum3m0, 4'b0}), 8'b0};
			p3outm0 <= p2sum0m0 + p2sum1m0;

			// =============== mult 1 ============= //
			p0r0m1 <= mac_vectA_1[3:0]  * mac_vectB_1[3:0];
			p0r1m1 <= mac_vectA_1[3:0]  * mac_vectB_1[7:4];
			p0r2m1 <= mac_vectA_1[3:0]  * mac_vectB_1[11:8];
			p0r3m1 <= mac_vectA_1[3:0]  * mac_vectB_1[15:12];
			p0r4m1 <= mac_vectA_1[7:4]  * mac_vectB_1[3:0];
			p0r5m1 <= mac_vectA_1[7:4]  * mac_vectB_1[7:4];
			p0r6m1 <= mac_vectA_1[7:4]  * mac_vectB_1[11:8];
			p0r7m1 <= mac_vectA_1[7:4]  * mac_vectB_1[15:12];
			p0r8m1 <= mac_vectA_1[11:8]  * mac_vectB_1[3:0];
			p0r9m1 <= mac_vectA_1[11:8]  * mac_vectB_1[7:4];
			p0r10m1 <= mac_vectA_1[11:8]  * mac_vectB_1[11:8];
			p0r11m1 <= mac_vectA_1[11:8]  * mac_vectB_1[15:12];
			p0r12m1 <= mac_vectA_1[15:12]  * mac_vectB_1[3:0];
			p0r13m1 <= mac_vectA_1[15:12]  * mac_vectB_1[7:4];
			p0r14m1 <= mac_vectA_1[15:12]  * mac_vectB_1[11:8];
			p0r15m1 <= mac_vectA_1[15:12]  * mac_vectB_1[15:12];
			p1sum0m1 <= {12'b0, p0r0m1} +
					  {8'b0, p0r1m1, 4'b0} +
					  {4'b0, p0r2m1, 8'b0} +
					  {p0r3m1, 12'b0};
			p1sum1m1 <= {12'b0, p0r4m1} +
					  {8'b0, p0r5m1, 4'b0} +
					  {4'b0, p0r6m1, 8'b0} +
					  {p0r7m1, 12'b0};
			p1sum2m1 <= {12'b0, p0r8m1} +
					  {8'b0, p0r9m1, 4'b0} +
					  {4'b0, p0r10m1, 8'b0} +
					  {p0r11m1, 12'b0};
			p1sum3m1 <= {12'b0, p0r12m1} +
					  {8'b0, p0r13m1, 4'b0} +
					  {4'b0, p0r14m1, 8'b0} +
					  {p0r15m1, 12'b0};
			p2sum0m1 <= {8'b0, ({4'b0, p1sum0m1} + {p1sum1m1, 4'b0})};
			p2sum1m1 <= {({4'b0, p1sum2m1} + {p1sum3m1, 4'b0}), 8'b0};
			p3outm1 <= p2sum0m1 + p2sum1m1;

			// =============== mult 2 ============= //
			p0r0m2 <= mac_vectA_2[3:0]  * mac_vectB_2[3:0];
			p0r1m2 <= mac_vectA_2[3:0]  * mac_vectB_2[7:4];
			p0r2m2 <= mac_vectA_2[3:0]  * mac_vectB_2[11:8];
			p0r3m2 <= mac_vectA_2[3:0]  * mac_vectB_2[15:12];
			p0r4m2 <= mac_vectA_2[7:4]  * mac_vectB_2[3:0];
			p0r5m2 <= mac_vectA_2[7:4]  * mac_vectB_2[7:4];
			p0r6m2 <= mac_vectA_2[7:4]  * mac_vectB_2[11:8];
			p0r7m2 <= mac_vectA_2[7:4]  * mac_vectB_2[15:12];
			p0r8m2 <= mac_vectA_2[11:8]  * mac_vectB_2[3:0];
			p0r9m2 <= mac_vectA_2[11:8]  * mac_vectB_2[7:4];
			p0r10m2 <= mac_vectA_2[11:8]  * mac_vectB_2[11:8];
			p0r11m2 <= mac_vectA_2[11:8]  * mac_vectB_2[15:12];
			p0r12m2 <= mac_vectA_2[15:12]  * mac_vectB_2[3:0];
			p0r13m2 <= mac_vectA_2[15:12]  * mac_vectB_2[7:4];
			p0r14m2 <= mac_vectA_2[15:12]  * mac_vectB_2[11:8];
			p0r15m2 <= mac_vectA_2[15:12]  * mac_vectB_2[15:12];
			p1sum0m2 <= {12'b0, p0r0m2} +
					  {8'b0, p0r1m2, 4'b0} +
					  {4'b0, p0r2m2, 8'b0} +
					  {p0r3m2, 12'b0};
			p1sum1m2 <= {12'b0, p0r4m2} +
					  {8'b0, p0r5m2, 4'b0} +
					  {4'b0, p0r6m2, 8'b0} +
					  {p0r7m2, 12'b0};
			p1sum2m2 <= {12'b0, p0r8m2} +
					  {8'b0, p0r9m2, 4'b0} +
					  {4'b0, p0r10m2, 8'b0} +
					  {p0r11m2, 12'b0};
			p1sum3m2 <= {12'b0, p0r12m2} +
					  {8'b0, p0r13m2, 4'b0} +
					  {4'b0, p0r14m2, 8'b0} +
					  {p0r15m2, 12'b0};
			p2sum0m2 <= {8'b0, ({4'b0, p1sum0m2} + {p1sum1m2, 4'b0})};
			p2sum1m2 <= {({4'b0, p1sum2m2} + {p1sum3m2, 4'b0}), 8'b0};
			p3outm2 <= p2sum0m2 + p2sum1m2;

			// =============== mult 3 ============= //
			p0r0m3 <= mac_vectA_3[3:0]  * mac_vectB_3[3:0];
			p0r1m3 <= mac_vectA_3[3:0]  * mac_vectB_3[7:4];
			p0r2m3 <= mac_vectA_3[3:0]  * mac_vectB_3[11:8];
			p0r3m3 <= mac_vectA_3[3:0]  * mac_vectB_3[15:12];
			p0r4m3 <= mac_vectA_3[7:4]  * mac_vectB_3[3:0];
			p0r5m3 <= mac_vectA_3[7:4]  * mac_vectB_3[7:4];
			p0r6m3 <= mac_vectA_3[7:4]  * mac_vectB_3[11:8];
			p0r7m3 <= mac_vectA_3[7:4]  * mac_vectB_3[15:12];
			p0r8m3 <= mac_vectA_3[11:8]  * mac_vectB_3[3:0];
			p0r9m3 <= mac_vectA_3[11:8]  * mac_vectB_3[7:4];
			p0r10m3 <= mac_vectA_3[11:8]  * mac_vectB_3[11:8];
			p0r11m3 <= mac_vectA_3[11:8]  * mac_vectB_3[15:12];
			p0r12m3 <= mac_vectA_3[15:12]  * mac_vectB_3[3:0];
			p0r13m3 <= mac_vectA_3[15:12]  * mac_vectB_3[7:4];
			p0r14m3 <= mac_vectA_3[15:12]  * mac_vectB_3[11:8];
			p0r15m3 <= mac_vectA_3[15:12]  * mac_vectB_3[15:12];
			p1sum0m3 <= {12'b0, p0r0m3} +
					  {8'b0, p0r1m3, 4'b0} +
					  {4'b0, p0r2m3, 8'b0} +
					  {p0r3m3, 12'b0};
			p1sum1m3 <= {12'b0, p0r4m3} +
					  {8'b0, p0r5m3, 4'b0} +
					  {4'b0, p0r6m3, 8'b0} +
					  {p0r7m3, 12'b0};
			p1sum2m3 <= {12'b0, p0r8m3} +
					  {8'b0, p0r9m3, 4'b0} +
					  {4'b0, p0r10m3, 8'b0} +
					  {p0r11m3, 12'b0};
			p1sum3m3 <= {12'b0, p0r12m3} +
					  {8'b0, p0r13m3, 4'b0} +
					  {4'b0, p0r14m3, 8'b0} +
					  {p0r15m3, 12'b0};
			p2sum0m3 <= {8'b0, ({4'b0, p1sum0m3} + {p1sum1m3, 4'b0})};
			p2sum1m3 <= {({4'b0, p1sum2m3} + {p1sum3m3, 4'b0}), 8'b0};
			p3outm3 <= p2sum0m3 + p2sum1m3;

			p4val_m0m1 <= p3outm0 + p3outm1;
			p4val_m2m3 <= p3outm2 + p3outm3;

			p5out <= p4val_m0m1 + p4val_m2m3;


			valid_read_reg <= 1'b0;

			case (curr_state)
				INIT: begin
					valid_read_reg <= 1'b0;
					write_addr_reg <= 6'b0;
					read_addr_reg <= 6'b0;
					mem_full_flag <= 1'b0;
				end

				IDLE_WRITE: begin
					valid_read_reg <= 1'b0;
					if (pipe5_en && ~mem_full_flag) begin
						write_addr_reg <= write_addr_reg + 1;
						if (write_addr_reg == 6'h3f) begin
							read_addr_reg <= 6'b0;
							mem_full_flag <= 1'b1;
						end
					end
				end

				FULL: begin
					write_addr_reg <= 6'b0;
				end

				READ: begin
					// reset the addresses and memory when complete
					valid_read_reg <= 1'b1;
					if (read_addr_reg == 6'h3f) begin
						write_addr_reg <= 6'b0;
						mem_full_flag <= 1'b0;
					end else begin
						read_addr_reg <= read_addr_reg + 1;
					end
				end

				default: begin
					// next_state <= INIT;
					// nothing happens
				end
			endcase 
		end
    end

    always_comb begin
        next_state = curr_state;
        RDY_mac = 1'b0;
		RDY_blockRead = 1'b0;
        EN_writeMem = 1'b0;
        EN_readMem = 1'b0;
        writeMem_val = p5out;

        writeMem_addr = write_addr_reg;
        readMem_addr = read_addr_reg;

        VALID_memVal = valid_read_reg;

        case (curr_state)
            INIT: begin
                RDY_mac = 1'b0;
                if (~mem_full_flag)
                    next_state = IDLE_WRITE;
            end

            IDLE_WRITE: begin
                RDY_mac = 1'b1;

                if (pipe5_en && ~mem_full_flag)
                    EN_writeMem = 1'b1;

                if (mem_full_flag) begin 
                    RDY_mac = 1'b0;
                    next_state = FULL;
                end
            end
            
            FULL: begin
                RDY_mac = 1'b0;
                RDY_blockRead = 1'b1;

                if (EN_blockRead && mem_full_flag)
                    next_state = READ;

            end
            
            READ: begin
                RDY_mac = 1'b0;
                EN_readMem = 1'b1;

                if (read_addr_reg == 6'h3f)
                    next_state = IDLE_WRITE;
            end

            default:
                next_state = INIT;
        endcase
    end

endmodule: mac
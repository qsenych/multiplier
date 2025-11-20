module multiplier #(parameter N = 32) (
    input logic CLK, EN_mult, EN_blockRead, rst_n,
    input logic [15:0] mult_input0, 
    input logic [15:0] mult_input1,
    input logic [N - 1:0] readMem_val,
    output logic RDY_mult, EN_readMem, EN_writeMem, VALID_memVal,
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

    logic [N - 1:0] pipe1_op0, pipe1_op1, pipe2_val;
    logic pipe1_en;
    logic pipe2_en;

    logic valid_read_reg;

    assign memVal_data = readMem_val;

    // writeMem_addr starts at 0, increments by 1 every multiplication
    // readMem_addr starts at 0, increments by 1 once reading starts
    //      Can't change once startec
    always_ff @(posedge CLK) begin
		if (!rst_n) begin
			curr_state <= INIT;
			pipe1_en <= 0;
		end else begin
			curr_state <= next_state;

			pipe1_op0 <= mult_input0;
			pipe1_op1 <= mult_input1;
			pipe1_en <= EN_mult;

			pipe2_val <= pipe1_op0 * pipe1_op1;
			pipe2_en <= pipe1_en;

			valid_read_reg <= (curr_state == READ);

			case (curr_state)
				INIT: begin
					write_addr_reg <= 6'b0;
					read_addr_reg <= 6'b0;
					mem_full_flag <= 1'b0;
				end

				IDLE_WRITE: begin
					if (pipe2_en && ~mem_full_flag) begin
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
        RDY_mult = 1'b0;
        EN_writeMem = 1'b0;
        EN_readMem = 1'b0;
        writeMem_val = pipe2_val;

        writeMem_addr = write_addr_reg;
        readMem_addr = read_addr_reg;

        VALID_memVal = valid_read_reg;

        case (curr_state)
            INIT: begin
                RDY_mult = 1'b0;
                if (~mem_full_flag)
                    next_state = IDLE_WRITE;
            end

            IDLE_WRITE: begin
                RDY_mult = 1'b1;

                if (pipe2_en && ~mem_full_flag)
                    EN_writeMem = 1'b1;

                if (mem_full_flag) begin 
                    RDY_mult = 1'b0;
                    next_state = FULL;
                end
            end
            
            FULL: begin
                RDY_mult = 1'b0;

                if (EN_blockRead && mem_full_flag)
                    next_state = READ;

            end
            
            READ: begin
                RDY_mult = 1'b0;
                EN_readMem = 1'b1;

                if (read_addr_reg == 6'h3f)
                    next_state = IDLE_WRITE;
            end

            default:
                next_state = INIT;
        endcase
    end
endmodule: multiplier

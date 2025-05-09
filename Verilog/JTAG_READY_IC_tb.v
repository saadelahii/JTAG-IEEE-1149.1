module JTAG_READY_IC_tb();
	// regs to drive JTAG related ports
	reg TDI,TCK,TMS,TRST;
	// regs to drive the inputs of the cut
	reg a,b,c,d;
	// wires to get cut outputs and JTAG TDO
	wire i,j,TDO;
	wire [3:0] STATE;
	//	wiring up the JTAG_READY_IC module
	JTAG_READY_IC JTAG_READY_IC(TDI,TCK,TMS,TRST,a,b,c,d,i,j,TDO,STATE);
	// regs to print debug messages
	reg[31*8:0] state_str;
	reg[8*64:0] str_debug;
  // for for-loop
  integer k;
	// Simulate clock
	initial begin
		TCK = 0;
		forever begin
			#5 TCK =! TCK;
		end
	end
	// reset sequence
	initial begin
		str_debug =0;
		state_str=0;
		{TDI,TMS,TRST,a,b,c,d} = 0;
		#10
		TRST = 1;
		#10
		TRST = 0;
	end
	// tasks to automate setup sequence 
	task set_fsm_to_shift_ir;
		begin
		  str_debug = "set_fsm_to_shift_ir";
			TMS=0;
			#10
			TMS=1;
			#10
			TMS=1;
			#10
			TMS=0;
			#20;
		end
	endtask
	
	task set_fsm_to_shift_dr;
		begin
		  str_debug = "set_fsm_to_shift_dr";
			// setup fsm seq for shift_dr
			TMS = 1; 
			#10;
			TMS = 0; 
			#10;
		end
	endtask
	
	task shift_ir(input [1:0] instr);
		begin

			str_debug = "shift_ir";
			// shift instr
			TDI=instr[0];
			#10
			TDI=instr[1];			
			str_debug = "run_test_instr_ir";
			TMS=1;
			#10
			TMS=1;
			#10
			TMS=0;
			#10;
		end
	endtask
	
	task shift_dr(input [7:0] data);
		begin
			begin
			  str_debug = "shift_dr";
				for (k = 0; k < 8; k = k + 1) begin
					TDI = data[k];
					// shift untill last bit
					TMS = (k == 7) ? 1 : 0; 
					#10;
				end
				// EXIT1-DR -> UPDATE-DR -> IDLE
				TMS = 1; 
				#10;
				TMS = 0; 
				#10;
			end
		end
	endtask
	
	
	// main test sequence
	initial begin
		// wait 2 cycles for the reset
		#20 
		// Set Intruction
		set_fsm_to_shift_ir();
		shift_ir(2'b00);
		
		// Testing BYPASS register Shifting
		set_fsm_to_shift_dr();
		shift_dr(8'b10101010);
		#100;
	end
	
	// Always block to toggle state_str on each cycle
	// for debugging purposes
	always @ (*)
	begin
		case (STATE)
			4'd0:  state_str = "TEST_LOGIC_RESET";
			4'd1:  state_str = "RUN_TEST_IDLE";
			4'd2:  state_str = "SELECT_DR_SCAN";
			4'd3:  state_str = "CAPTURE_DR";
			4'd4:  state_str = "SHIFT_DR";
			4'd5:  state_str = "EXIT1_DR";
			4'd6:  state_str = "PAUSE1_DR";
			4'd7:  state_str = "EXIT2_DR";
			4'd8:  state_str = "UPDATE_DR";
			4'd9:  state_str = "SELECT_IR_SCAN";
			4'd10: state_str = "CAPTURE_IR";
			4'd11: state_str = "SHIFT_IR";
			4'd12: state_str = "EXIT1_IR";
			4'd13: state_str = "PAUSE1_IR";
			4'd14: state_str = "EXIT2_IR";
			4'd15: state_str = "UPDATE_IR";
			default: state_str = "UNKNOWN";
		endcase
  end
endmodule
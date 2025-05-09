module JTAG_READY_IC_SAMPLE_tb();
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
		{TDI,TMS,TRST} = 0;
		// set cut inputs to perfom SAMple
		// 
		{a, b, c, d} = 4'b0111;
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
			str_debug = "run test instr";
			TMS=1;
			#10
			TMS=1;
			#10
			TMS=0;
			#10;
		end
	endtask
	
	task shift_dr(input [5:0] preload_data);
		begin
			begin
			  str_debug = "shift_dr";
				for (k = 0; k < 6; k = k + 1) begin
					TDI = preload_data[k];
					TMS = (k == 5) ? 1 : 0; // shift untill last bit
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
		// set instruction to SAMple
		set_fsm_to_shift_ir();
		shift_ir(2'b01);
		
		// Testing SAMPLE while preloading the next vector (1001)
		set_fsm_to_shift_dr();
		shift_dr(6'b100100); // 4 MSBs relate to CUT input
			
		// change IR to EXTTEST
		set_fsm_to_shift_ir();
		shift_ir(2'b10);
		
		// shift out extest responce
		set_fsm_to_shift_dr();
		shift_dr(6'b000000);
		#200;
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
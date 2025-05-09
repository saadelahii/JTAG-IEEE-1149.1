module TAP_CONTROLLER_FSM(
	TCK,
	TMS,
	TRST,
	STATE,
	ShiftIR,
	CaptureIR,
	UpdateIR,
	ClockIR,
	ShiftDR,
	CaptureDR,
	UpdateDR,
	ClockDR
);
// Defining known FSM states
localparam TEST_LOGIC_RESET=4'd0;
localparam RUN_TEST_IDLE	=4'd1;
localparam SELECT_DR_SCAN	=4'd2;
localparam CAPTURE_DR		=4'd3;
localparam SHIFT_DR			=4'd4;
localparam EXIT1_DR			=4'd5;
localparam PAUSE1_DR			=4'd6;
localparam EXIT2_DR			=4'd7;
localparam UPDATE_DR			=4'd8;
localparam SELECT_IR_SCAN	=4'd9;
localparam CAPTURE_IR		=4'd10;
localparam SHIFT_IR			=4'd11;
localparam EXIT1_IR			=4'd12;
localparam PAUSE1_IR			=4'd13;
localparam EXIT2_IR			=4'd14;
localparam UPDATE_IR			=4'd15;

// Defining necessary ports
input TCK,TMS,TRST;
output[3:0] STATE;
// addition of control signal ports
output ShiftIR,CaptureIR,UpdateIR,ClockIR;
output ShiftDR,CaptureDR,UpdateDR,ClockDR;
// Defining FSM memory
reg[3:0] tap_state;
// Assigning STATE output to FSM Memory
assign STATE=tap_state;
// Assigning FSM control signals (delay added for simulation timing synchr)
assign #1 ShiftIR=(tap_state==SHIFT_IR);
assign #1 CaptureIR=(tap_state==CAPTURE_IR || tap_state==SHIFT_IR);
assign #1 UpdateIR=(tap_state==UPDATE_IR);
assign #1 ShiftDR=(tap_state==SHIFT_DR);
assign #1 CaptureDR=(tap_state==CAPTURE_DR || tap_state==SHIFT_DR)?1'b1:1'b0;
assign #1 UpdateDR=(tap_state==UPDATE_DR);
// enable clock for BSC and IR cell shifts
assign ClockDR=(tap_state==SHIFT_DR)?TCK:1'b0;
assign ClockIR=(tap_state==SHIFT_IR)?TCK:1'b0;
// always block for TCK and TRST
always @ (posedge TCK or posedge TRST)
  begin
  // if asyn TRST set tap_state to 0
  if (TRST)
    tap_state<=0;
  else begin
  // switch case for FSM implementation (taken from TAP_CONTROLLER diagram)
  case(tap_state)
		TEST_LOGIC_RESET:	tap_state<=(TMS)?TEST_LOGIC_RESET:RUN_TEST_IDLE;
		RUN_TEST_IDLE:		tap_state<=(TMS)?SELECT_DR_SCAN:RUN_TEST_IDLE;
		SELECT_DR_SCAN:	tap_state<=(TMS)?SELECT_IR_SCAN:CAPTURE_DR;
		CAPTURE_DR:			tap_state<=(TMS)?EXIT1_DR:SHIFT_DR;
		SHIFT_DR:			tap_state<=(TMS)?EXIT1_DR:SHIFT_DR;
		EXIT1_DR:			tap_state<=(TMS)?UPDATE_DR:PAUSE1_DR;
		PAUSE1_DR:			tap_state<=(TMS)?EXIT2_DR:PAUSE1_DR;
		EXIT2_DR:			tap_state<=(TMS)?UPDATE_DR:RUN_TEST_IDLE;
		UPDATE_DR:			tap_state<=(TMS)?SELECT_DR_SCAN:RUN_TEST_IDLE;
		SELECT_IR_SCAN:	tap_state<=(TMS)?TEST_LOGIC_RESET:CAPTURE_IR;
		CAPTURE_IR:			tap_state<=(TMS)?EXIT1_IR:SHIFT_IR;
		SHIFT_IR:			tap_state<=(TMS)?EXIT1_IR:SHIFT_IR;
		EXIT1_IR:			tap_state<=(TMS)?UPDATE_IR:PAUSE1_IR;
		PAUSE1_IR:			tap_state<=(TMS)?EXIT2_IR:PAUSE1_IR;
		EXIT2_IR:			tap_state<=(TMS)?UPDATE_IR:SHIFT_IR;
		UPDATE_IR:			tap_state<=(TMS)?SELECT_DR_SCAN:RUN_TEST_IDLE;
		default: 			tap_state<= TEST_LOGIC_RESET;	
	endcase	
	end
  end
endmodule

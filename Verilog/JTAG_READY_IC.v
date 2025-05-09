module JTAG_READY_IC(TDI,TCK,TMS,TRST,a,b,c,d,i,j,TDO,STATE);
	// ports for the JTAG ready ic
	input TDI,TCK,TMS,TRST,a,b,c,d;
	output i,j,TDO;
	output[3:0] STATE;
	// wires to wire up tap controller signals with JTAG_READY_CUT
	wire ShiftIR,CaptureIR,UpdateIR;
	wire ShiftDR,CaptureDR,UpdateDR;
	
	wire ClockIR,ClockDR;
	// wire bus to wire instruction port of the TAP_CONTROLLER_FSM
	wire[1:0] Instruction;
	
	// instruction decode logic based on instruction bus
	// to set mode and MUX_OUT_SEL
	localparam [1:0]
	BYPASS  = 2'b00,
	SAMPLE  = 2'b01,
	EXTEST  = 2'b10;

	wire MUX_OUT_SEL;
	wire Mode;
	
	wire instr_bypass  = (Instruction == BYPASS);
	wire instr_sample  = (Instruction == SAMPLE);
	wire instr_exttest = (Instruction == EXTEST);
	
	assign MUX_OUT_SEL = instr_sample | instr_exttest;
	assign Mode        = instr_exttest;   
	
	// output mux to select between cut output or IR output
	wire ir_tdo;
	wire cut_mux_out;
		
	wire select;
	assign select=(ShiftIR==1 || CaptureIR==1 || UpdateIR==1);
	
	wire mux_ir_cut;
	assign mux_ir_cut=(select)?ir_tdo:cut_mux_out;
	// negative edge output FF declaration and wiring
	reg ff;
	assign TDO = ff;
	always @(negedge TCK or posedge TRST) begin
		if(TRST)
			ff<=0;
		else begin
			ff<=mux_ir_cut;
		end
	end
	// wiring up the tap controller IO
	TAP_CONTROLLER_FSM tap_controller(
		.TCK(TCK),
		.TMS(TMS),
		.TRST(TRST),
		.STATE(STATE),
		.ShiftIR(ShiftIR),
		.CaptureIR(CaptureIR),
		.UpdateIR(UpdateIR),
		.ShiftDR(ShiftDR),
		.CaptureDR(CaptureDR),
		.UpdateDR(UpdateDR),
		.ClockDR(ClockDR),
		.ClockIR(ClockIR)
	);
	// wiring up the cut
	JTAG_READY_CUT cut(
		.TRST(TRST),
		.TDI(TDI),
		.ShiftDR(ShiftDR),
		.ClockDR(ClockDR),
		.UpdateDR(UpdateDR),
		.CaptureDR(CaptureDR),
		.Mode(Mode),
		.MUX_OUT_SEL(MUX_OUT_SEL),
		.a(a),
		.b(b),
		.c(c),
		.d(d),
		.i(i),
		.j(j),
		.MUX_OUT(cut_mux_out)
	);	
	// LSB-first
	// wiring up 2 bit instruction register
	IR_2b ir(
		.TRST(TRST),
		.TDI(TDI),
		.ShiftIR(ShiftIR),
		.ClockIR(ClockIR),
		.UpdateIR(UpdateIR),
		.TDO(ir_tdo),
		.INSTR(Instruction)
	);
endmodule
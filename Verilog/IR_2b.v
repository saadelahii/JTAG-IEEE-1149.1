module IR_2b(TRST,TDI,ShiftIR,ClockIR,UpdateIR,TDO,INSTR);
	// declaration of necessary ports for 2bit IR
	input TRST,TDI,ShiftIR,ClockIR,UpdateIR;
	output TDO;
	output[1:0] INSTR;
	// wire to connect ir0 with ir1
	wire tdo1_tdi0;
	wire Data;
	// data BUS is not needed
	assign Data=0;
	// wiring up ir modules
	IR ir1(TRST,Data, TDI, ShiftIR, ClockIR, UpdateIR, INSTR[1], tdo1_tdi0);
	IR ir0(TRST,Data, tdo1_tdi0, ShiftIR, ClockIR, UpdateIR, INSTR[0], TDO);
endmodule
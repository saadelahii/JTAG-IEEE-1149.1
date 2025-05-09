module JTAG_READY_CUT(TRST,TDI,ShiftDR,ClockDR,UpdateDR,CaptureDR,Mode,MUX_OUT_SEL,a,b,c,d,i,j,MUX_OUT);
	// direct interface IO for the CUT
	input a,b,c,d;
	output i,j;
	// JTAG related IO
	input TRST,TDI,ShiftDR,ClockDR,UpdateDR,CaptureDR,Mode,MUX_OUT_SEL;
	output MUX_OUT;
	// wire for JTAG related blocks
	wire br_tdo,SO;
	// wires to wire up BSC to BSC
	wire bsca_bscb,bscb_bscc,bscc_bscd,bscd_bsci,bsci_bscj;
	// wires to wire up BSC to cut
	wire bsc_cut_a,bsc_cut_b,bsc_cut_c,bsc_cut_d;
	// wires to wire up cut to BSC
	wire cut_bsc_i,cut_bsc_j;
	// BSC for CUT inputs
	BSC bsc_a(TRST,a,TDI,ShiftDR,ClockDR,UpdateDR,Mode,bsca_bscb,bsc_cut_a);
	BSC bsc_b(TRST,b,bsca_bscb,ShiftDR,ClockDR,UpdateDR,Mode,bscb_bscc,bsc_cut_b);
	BSC bsc_c(TRST,c,bscb_bscc,ShiftDR,ClockDR,UpdateDR,Mode,bscc_bscd,bsc_cut_c);
	BSC bsc_d(TRST,d,bscc_bscd,ShiftDR,ClockDR,UpdateDR,Mode,bscd_bsci,bsc_cut_d);
	// BSC for CUT outputs - mode set to 0 just to get cut output response
	BSC bsc_i(TRST,cut_bsc_i,bscd_bsci,ShiftDR,ClockDR,UpdateDR,1'b0,bsci_bscj,i);	
	BSC bsc_j(TRST,cut_bsc_j,bsci_bscj,ShiftDR,ClockDR,UpdateDR,1'b0,SO,j);	
	// BR wire up
	BR br(ClockDR,TDI,CaptureDR,br_tdo);
	// CUT wire up
	CUT CUT(bsc_cut_a,bsc_cut_b,bsc_cut_c,bsc_cut_d,cut_bsc_i,cut_bsc_j);
	// assigning mux output 1: bsc_j_SO 0:BYPASS
	assign MUX_OUT=(MUX_OUT_SEL)?SO:br_tdo;
endmodule
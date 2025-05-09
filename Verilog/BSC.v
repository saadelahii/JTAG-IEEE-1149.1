module BSC(TRST,DI,SI,ShiftDR,ClockDR,UpdateDR,Mode,SO,DO);
// Defining necessary ports
input TRST,DI,SI,ShiftDR,ClockDR,UpdateDR,Mode;
output SO,DO;
// Defining internal BSC regs
reg CAP,UPD;
// Defining wiring for internal connections
wire mux_to_cap,cap_to_upd,upd_to_mux;
// assign mux in
assign mux_to_cap=(ShiftDR)?SI:DI;
// assign cap output
assign cap_to_upd=CAP;
// assign mux out
assign DO=(Mode)?upd_to_mux:DI;
// assign upd to mux
assign upd_to_mux=UPD;
// assign Shift out
assign SO=cap_to_upd;
// always block for CAP DFF
  always @ (posedge ClockDR or posedge TRST)
  begin
		if (TRST)
			 CAP<=0;
		  else begin
		 CAP<=mux_to_cap;
	  end
	end
// always block for UPD DFF
  always @ (posedge UpdateDR or posedge TRST)
  begin
	if (TRST)
		UPD<=0;
		else begin
		UPD<=cap_to_upd;
	end
  end
endmodule
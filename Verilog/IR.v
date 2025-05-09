`timescale 1ns/1ps	

module IR(TRST,Data, TDI, ShiftIR, ClockIR, UpdateIR, ParallelOut, TDO);
  
  input TRST,Data, TDI, ShiftIR, ClockIR, UpdateIR;
  output ParallelOut, TDO;
  
  wire Data, TDI, ShiftIR, ClockIR, UpdateIR, ParallelOut,TDO;
  reg SRFFQ, LFFQ;
  wire DfromMux;
  //here we create the Mux 
  assign DfromMux=(ShiftIR)?TDI:Data;
  assign TDO=SRFFQ;
  assign ParallelOut=LFFQ;
  //here we create the SRFF
  always @ (posedge ClockIR or posedge TRST)
  begin
	  if (TRST)
		 SRFFQ<=0;
	  else begin
		 SRFFQ<=DfromMux;
	  end
	end
  //here we create the LFF
  always @ (posedge UpdateIR or posedge TRST) begin
	  if (TRST)
		 LFFQ<=0;
	  else begin
		 LFFQ<=SRFFQ;
	  end
	end 
endmodule
  
  

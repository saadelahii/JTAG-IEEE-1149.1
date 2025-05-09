module BR(ClockDR,TDI,CaptureDR,TDO);
// Defining necessary ports
input ClockDR,TDI,CaptureDR;
output TDO;
// Defining wiring for internal connections
wire tdi_and_captureDR;
// Defining internal BR reg
reg tdo_dff;
// assign AND gate
assign tdi_and_captureDR = TDI&CaptureDR;
// assign TDO
assign TDO = tdo_dff;
// always block for TDO DFF
 always @ (posedge ClockDR)
  begin
    tdo_dff<=tdi_and_captureDR;
end
endmodule
module address_generator(
  input clk,
  input rstn,
  input [13:0] start_addr,
  input [13:0] end_addr,
  input in_valid,
  output [13:0] addr,
  output done
);

wire [13:0] start_addr_flopped;
wire [13:0] end_addr_flopped;

wire counting;
reg next_counting;

reg [13:0] next_addr;

dffre #(.WIDTH(14)) start_addr_ff(
  .clk(clk),
  .r(~rst),
  .e(in_valid),
  .d(start_addr),
  .q(start_addr_flopped)
);

dffre #(.WIDTH(14)) end_addr_ff(
  .clk(clk),
  .r(~rst),
  .e(in_valid),
  .d(end_addr),
  .q(end_addr_flopped)
);


dffre #(.WIDTH(1)) count(
  .clk(clk),
  .r(~rstn),
  .e(in_valid),
  .d(next_counting),
  .q(counting)
);

always @(*) begin
  if (counting) begin
    next_counting = ~done;
  end else begin
    next_counting = in_valid;
  end
end

dffre #(.WIDTH(14)) counter(
  .clk(clk),
  .r(~rstn),
  .en(counting),
  .d(next_addr),
  .q(addr)
);

always @(*) begin
  if (counting) begin
    next_addr = addr + 1;
  end else begin
    next_addr = start_addr;
  end
end

assign done = (addr == end_addr);

endmodule

`timescale 1ns / 1ps

// simple block ram
module my_ram (
    input clk,
    input wen,
    input [13:0] addr,
    input [15:0] din,
    output [15:0] dout
);

reg [15:0] ram [16383:0];
reg [15:0] dout;

always @(posedge clk)
begin
    if (wen) begin
        ram[addr] <= din;
    end
    dout <= ram[addr];
end

endmodule

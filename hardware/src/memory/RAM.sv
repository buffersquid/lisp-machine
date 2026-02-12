`timescale 1ns / 1ps
`default_nettype none

module RAM #(
  parameter ADDR_WIDTH,
  parameter DATA_WIDTH
)(
  input wire clk,
  input wire write_enable,
  input wire [ADDR_WIDTH-1:0] addr,
  input wire [DATA_WIDTH-1:0] write_data,
  output logic [DATA_WIDTH-1:0] read_data
);

  (* ram_style = "block" *)
  reg [DATA_WIDTH-1:0] ram [0:(1 << ADDR_WIDTH)-1];

  always_ff @(posedge clk) begin
    if (write_enable) ram[addr] <= write_data;
    read_data <= ram[addr];
  end
endmodule

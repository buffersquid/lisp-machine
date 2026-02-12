`timescale 1ns / 1ps
`default_nettype none

`include "../lisp.sv"

module ROM #(
  parameter ADDR_WIDTH,
  parameter DATA_WIDTH
)(
  input  wire  clk,
  input  wire  [ADDR_WIDTH-1:0] addr,
  output logic [DATA_WIDTH-1:0] data_out
);
  (* rom_style = "block" *)
  reg [DATA_WIDTH-1:0] rom [0:(1 << ADDR_WIDTH)-1];

  initial begin
    rom['h0] = lisp::NIL;

    rom['h1] = lisp::TYPE_NUMBER;
    rom['h2] = 8'h12;
    rom['h3] = lisp::TYPE_NUMBER;
    rom['h4] = 8'h34;

    // cons primitive
    rom['h5] = lisp::TYPE_FUNC_PRIM;
    rom['h6] = lisp::TYPE_PRIM_CONS;
    rom['h7] = lisp::NIL;
    rom['h8] = lisp::NIL;

    // (cons 12 34) = (cons . (12 . (34 . NIL)))
    // (CONS 34 NIL)
    rom['h9] = lisp::TYPE_CONS;
    rom['hA] = 'h3;
    rom['hB] = lisp::NIL;

    // (CONS 12 (CONS 34 NIL))
    rom['hC] = lisp::TYPE_CONS;
    rom['hD] = 'h1;
    rom['hE] = 'h9;

    // (CONS cons-primitive (CONS 12 (CONS 34 NIL)))
    rom['hF]  = lisp::TYPE_CONS;
    rom['h10] = 'h5;
    rom['h11] = 'hC;

    // car primitive
    rom['h12] = lisp::TYPE_FUNC_PRIM;
    rom['h13] = lisp::TYPE_PRIM_CAR;
    rom['h14] = lisp::NIL;
    rom['h15] = lisp::NIL;

    // (CONS (cons 12 34) NIL)
    rom['h16] = lisp::TYPE_CONS;
    rom['h17] = 'hF;
    rom['h18] = lisp::NIL;

    // (CONS car-primitive (CONS (cons 12 34) NIL))
    rom['h19] = lisp::TYPE_CONS;
    rom['h1A] = 'h12;
    rom['h1B] = 'h16;
  end

  always_ff @(posedge clk) begin
    data_out <= rom[addr];
  end
endmodule

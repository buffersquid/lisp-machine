`ifndef LISP_SV
`define LISP_SV

`timescale 1ns / 1ps
`default_nettype none

package lisp;
  //────────────────────────────────────────────────────────────
  // Default Values
  //────────────────────────────────────────────────────────────
  // 2^12 = 4K words = 4096 addresses
  localparam addr_width = 12;
  // 8 bits per address, so 8-bit computer
  localparam data_width = 8;

  //────────────────────────────────────────────────────────────
  // Basic Memory Types
  //────────────────────────────────────────────────────────────
  typedef enum logic [data_width-1:0] {
    TYPE_NUMBER,
    TYPE_CONS,
    TYPE_FUNC_PRIM,
    TYPE_CLINK_HEADER
  } header_t;

  typedef enum logic [data_width-1:0] {
    TYPE_PRIM_CONS,
    TYPE_PRIM_CAR,
    TYPE_PRIM_CDR
  } primitive_t;

  localparam NIL = 8'h0;

  //────────────────────────────────────────────────────────────
  // State Variables
  //────────────────────────────────────────────────────────────
  typedef enum {
    Boot,
    SelectExpr,
    StartFetch,
    MemWait,
    Eval,
    Halt,
    Error
  } state_t;

endpackage

`endif

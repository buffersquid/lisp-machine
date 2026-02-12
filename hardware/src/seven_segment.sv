`timescale 1ns/1ps
`default_nettype none

module seven_segment (
  input  wire         clk,       // 100 MHz system clock
  input  wire  [15:0] hex,       // four 4‑bit digits
  input  wire         error,
  input  wire  [ 3:0] error_code,
  output logic [ 7:0] cathodes,
  output logic [ 3:0] anodes
);

  //─────────────────────────────────────────────────────
  // parameters & lookups
  //─────────────────────────────────────────────────────
  localparam int ClkFreq   = 100_000_000;
  localparam int RefreshHz = 500;
  localparam int CountMax  = ClkFreq/RefreshHz/2;

  typedef enum logic [1:0] { DIG0, DIG1, DIG2, DIG3 } digit_t;

  // 0‑F → segment patterns
  localparam logic [7:0] SegmentLookup [0:15] = '{
    8'h81, 8'hCF, 8'h92, 8'h86,
    8'hCC, 8'hA4, 8'hA0, 8'h8F,
    8'h80, 8'h8C, 8'h88, 8'hE0,
    8'hB1, 8'hC2, 8'hB0, 8'hB8
  };

  localparam logic [7:0] Error [0:2] = '{
    // Spells Err
    8'hFA, 8'hFA, 8'hB0
  };
  logic [7:0] display_error [0:3];
  // Add the error code to the output
  assign display_error = {SegmentLookup[error_code], Error};

  // which anode to drive active (low)
  localparam logic [3:0] AnodeLookup [0:3] = '{4'b1110,4'b1101,4'b1011,4'b0111};

  //─────────────────────────────────────────────────────
  // clock divider → 500 Hz refresh clock
  //─────────────────────────────────────────────────────
  logic [31:0]         div_counter = 0;
  logic tick;
  always_ff @(posedge clk) begin
    if (div_counter == CountMax-1) begin
      div_counter <= 0;
      tick        <= 1'b1;
    end else begin
      div_counter <= div_counter + 1;
      tick        <= 1'b0;
    end
  end

  //─────────────────────────────────────────────────────
  // digit‐scan & lookup
  //─────────────────────────────────────────────────────
  digit_t current_digit = DIG0;
  always_ff @(posedge clk) begin
    if (tick) begin
      // rotate through DIG0→DIG1→DIG2→DIG3→DIG0
      case (current_digit)
        DIG0: current_digit <= DIG1;
        DIG1: current_digit <= DIG2;
        DIG2: current_digit <= DIG3;
        DIG3: current_digit <= DIG0;
        default: current_digit <= DIG0;
      endcase

      // update anodes and cathodes from lookup tables
      anodes   <= AnodeLookup[current_digit];
      cathodes <= error ? display_error[current_digit] : SegmentLookup[hex[4*current_digit +: 4]];
    end
  end

endmodule

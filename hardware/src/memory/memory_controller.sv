// Open question:
// Why do I need to latch for reading, but not for writing?
// Feels like some stinky code...
`timescale 1ns / 1ps
`default_nettype none

module memory_controller #(
  parameter ADDR_WIDTH,
  parameter DATA_WIDTH,
  // Only for testbench. Skips booting sequence and allows for direct memory
  // poking.
  parameter BYPASS_BOOT = 0
)(
  input  wire clk,
  input  wire rst,
  output logic boot_done,

  // Active after boot
  input wire   write_enable, read_enable,
  input wire   [ADDR_WIDTH-1:0] addr,
  input wire   [DATA_WIDTH-1:0] write_data,
  output logic [DATA_WIDTH-1:0] read_data,
  output logic memory_error
);
  //────────────────────────────────────────────────────────────
  // Types
  //────────────────────────────────────────────────────────────
  typedef enum {
    FETCH_ROM,
    WRITE_RAM,
    RUNNING,
    ERROR
  } boot_state_t;

  boot_state_t state, next_state;
  logic [ADDR_WIDTH-1:0] boot_addr;
  logic [DATA_WIDTH-1:0] rom_data;

  ROM #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) rom (
    .clk(clk),
    .addr(boot_addr),
    .data_out(rom_data)
  );

  logic ram_write_enable_internal;
  logic [ADDR_WIDTH-1:0] ram_addr_internal, addr_latch;
  logic [DATA_WIDTH-1:0] ram_write_data_internal;
  logic [DATA_WIDTH-1:0] ram_read_data_internal;

  RAM #(
    .ADDR_WIDTH(ADDR_WIDTH),
    .DATA_WIDTH(DATA_WIDTH)
  ) ram (
    .clk(clk),
    .write_enable(ram_write_enable_internal),
    .addr(ram_addr_internal),
    .write_data(ram_write_data_internal),
    .read_data(ram_read_data_internal)
  );

  always_ff @(posedge clk) begin
    if (rst) begin
      addr_latch  <= '0;
      if (BYPASS_BOOT) begin
        state <= RUNNING;
      end else begin
        state <= FETCH_ROM;
        boot_addr <= {ADDR_WIDTH{1'b0}};
      end
    end else begin
      state <= next_state;
      if (state == WRITE_RAM) begin
        boot_addr <= boot_addr + 1;
      end

      if (state == RUNNING) begin
        if (read_enable) begin
          addr_latch <= addr;
        end
      end
    end
  end

  always_comb begin
    next_state = state;

    // Defaults:
    ram_write_enable_internal = 1'b0;
    ram_addr_internal = addr;
    ram_write_data_internal = write_data;
    boot_done = 1'b0;
    memory_error = 1'b0;

    case (state)
      FETCH_ROM: begin
        ram_addr_internal = boot_addr;
        next_state = WRITE_RAM;
      end

      WRITE_RAM: begin
        ram_write_enable_internal = 1'b1;
        ram_addr_internal = boot_addr;
        ram_write_data_internal = rom_data;

        if (boot_addr == {ADDR_WIDTH{1'b1}}) begin
          next_state = RUNNING;
        end else begin
          next_state = FETCH_ROM;
        end
      end

      RUNNING: begin
        // Pass external RAM interface to internal since now all memory
        // actions will be RAM based
        boot_done = 1'b1;
        ram_write_enable_internal = write_enable;
        if (write_enable) begin
          ram_addr_internal = addr;
        end else begin
          ram_addr_internal = addr_latch;
        end
        ram_write_data_internal = write_data;
      end

      ERROR: begin
        memory_error = 1'b1;
      end

      default: next_state = ERROR;
    endcase
  end

  assign read_data = ram_read_data_internal;

endmodule

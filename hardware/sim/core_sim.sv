`timescale 1ns / 1ps

`include "../src/lisp.sv"

module core_sim();
  logic clk = 0;
  logic rst = 0;
  logic btn_start = 0;
  logic [15:0] switches;
  logic [7:0]  cathodes;
  logic [3:0]  anodes;
  logic [15:0] leds;

  localparam int MemorySize = 1024;

  core d0 (
    .clk(clk),
    .rst(rst),
    .btn_start(btn_start),
    .switches(switches),
    .cathodes(cathodes),
    .anodes(anodes),
    .leds(leds)
  );
  defparam d0.mem.BYPASS_BOOT = 1;

  always #10 clk = ~clk;

  task clear_memory(input logic [lisp::data_width-1:0] mem[MemorySize]);
    begin
      for (int i = 0; i < MemorySize; i++) begin
        mem[i] = 16'h0000;
      end
    end
  endtask

  // Wait until system finishes execution
  task wait_until_done;
    while (d0.state.current !== lisp::Halt && d0.state.current !== lisp::Error) begin
      @(posedge clk);
    end
    // Three more cycles to let everything settle down
    for (int i = 0; i < 3; i++) begin
      @(posedge clk);
    end
  endtask

  // Main test function
  task run_expr_via_button(
    input logic [lisp::data_width-1:0] expr_value,
    input logic [lisp::data_width-1:0] mem_values[MemorySize],
    input logic [lisp::data_width-1:0] expected_val
  );
    begin
      // ───── Set switches to desired expr ───────
      switches = expr_value;
      btn_start = 0;

      // ───── Reset core and memory ───────────────
      rst = 1;
      for (int i = 0; i < 3; i++) @(posedge clk);
      rst = 0;
      @(posedge clk);

      // ───── Set memory contents ───────────────
      for (int i = 0; i < MemorySize; i++) begin
        d0.mem.ram.ram[i] = mem_values[i];
      end

      // ───── Pulse button to trigger start ──────
      btn_start = 1;
      @(posedge clk);
      btn_start = 0;
      @(posedge clk);

      // ───── Wait for completion ────────────────
      wait_until_done();

      // ───── Validate results ───────────────────
      if (d0.state.current == lisp::Error) begin
        $fatal(1, "Execution failed: error = %h", d0.error_code_reg);
      end else if (d0.val.current !== expected_val) begin
        $fatal(1, "Assertion failed: val = %h (expected %h)", d0.val.current, expected_val);
      end else begin
        $display("PASS: val = %h", d0.val.current);
      end
    end
  endtask

  initial begin
    logic [lisp::data_width-1:0] memory[MemorySize];
    clear_memory(memory);
    memory['h0] = lisp::NIL;

    memory['h1] = lisp::TYPE_NUMBER;
    memory['h2] = 8'h12;
    memory['h3] = lisp::TYPE_NUMBER;
    memory['h4] = 8'h34;

    // cons primitive
    memory['h5] = lisp::TYPE_FUNC_PRIM;
    memory['h6] = lisp::TYPE_PRIM_CONS;
    memory['h7] = lisp::NIL;
    memory['h8] = lisp::NIL;

    // (cons 12 34) = (cons . (12 . (34 . NIL)))
    // (CONS 34 NIL)
    memory['h9] = lisp::TYPE_CONS;
    memory['hA] = 'h3;
    memory['hB] = lisp::NIL;

    // (CONS 12 (CONS 34 NIL))
    memory['hC] = lisp::TYPE_CONS;
    memory['hD] = 'h1;
    memory['hE] = 'h9;

    // (CONS cons-primitive (CONS 12 (CONS 34 NIL)))
    memory['hF]  = lisp::TYPE_CONS;
    memory['h10] = 'h5;
    memory['h11] = 'hC;

    // car primitive
    memory['h12] = lisp::TYPE_FUNC_PRIM;
    memory['h13] = lisp::TYPE_PRIM_CAR;
    memory['h14] = lisp::NIL;
    memory['h15] = lisp::NIL;

    // (CONS (cons 12 34) NIL)
    memory['h16] = lisp::TYPE_CONS;
    memory['h17] = 'hF;
    memory['h18] = lisp::NIL;

    // (CONS car-primitive (CONS (cons 12 34) NIL))
    memory['h19] = lisp::TYPE_CONS;
    memory['h1A] = 'h12;
    memory['h1B] = 'h16;

    run_expr_via_button(8'h01, memory, 8'h34);

    $display("✅ All tests passed!");
    $finish;
  end

endmodule

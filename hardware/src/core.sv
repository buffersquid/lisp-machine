`timescale 1ns / 1ps
`default_nettype none

`include "lisp.sv"

module core (
  input  wire         clk,
  input  wire         rst,
  input  wire         btn_start,
  input  wire  [15:0] switches,
  output logic [ 7:0] cathodes,
  output logic [ 3:0] anodes,
  output logic [15:0] leds
);
  //────────────────────────────────────────────────────────────
  // Types
  //────────────────────────────────────────────────────────────
  // Error codes
  typedef enum logic [3:0] {
    NO_ERR,
    STATE_ERROR,
    MEM_ERROR,
    FETCH_ERROR,
    WRITE_ERROR,
    EVAL_ERROR,
    APPLY_ERROR
  } error_code_e;
  localparam logic [15:0] LED_ERROR   = 16'hFFFF;
  localparam logic [15:0] LED_HALT    = 16'h0001;
  error_code_e  error_code, error_code_reg;

  //────────────────────────────────────────────────────────────
  // Functions & Tasks
  //────────────────────────────────────────────────────────────
  task automatic send_error(
    input error_code_e error
  );
  begin
    error_code = error;
    state.next = lisp::Error;
  end
  endtask

  //────────────────────────────────────────────────────────────
  // Registers
  //────────────────────────────────────────────────────────────
  typedef struct packed {
    logic [lisp::data_width-1:0] current;
    logic [lisp::data_width-1:0] next;
  } reg_t;
  reg_t val, clink;

  typedef struct packed {
    logic [lisp::addr_width-1:0] current;
    logic [lisp::addr_width-1:0] next;
  } areg_t;
  areg_t expr;

  //────────────────────────────────────────────────────────────
  // Memory
  //────────────────────────────────────────────────────────────
  // Control signals
  logic start_fetch, fetch_done, fetch_error, mem_error;

  logic read_enable, boot_done, write_enable;
  logic [lisp::addr_width-1:0] addr_fetch;
  // Inputs
  logic [lisp::data_width-1:0] write_data;
  // Outputs
  logic [lisp::data_width-1:0] read_data;

  //────────────────────────────────────────────────────────────
  // Memory FETCH FSM Logic
  //────────────────────────────────────────────────────────────
  typedef enum {
    FETCH_IDLE,
    FETCH_TAG_REQ,
    FETCH_TAG_STORE,
    FETCH_VAL_REQ,
    FETCH_VAL_STORE,
    FETCH_CONS_CAR_REQ,
    FETCH_CONS_CAR_STORE,
    FETCH_CONS_CDR_REQ,
    FETCH_CONS_CDR_STORE,
    FETCH_FUNC_BODY_REQ,
    FETCH_FUNC_BODY_STORE,
    FETCH_FUNC_ARGS_REQ,
    FETCH_FUNC_ARGS_STORE,
    FETCH_FUNC_ENV_REQ,
    FETCH_FUNC_ENV_STORE,
    FETCH_DONE,
    FETCH_ERR
  } fetch_state_t;

  struct packed {
    fetch_state_t current;
    fetch_state_t next;
  } fetch_state;

  reg_t tag_reg;
  reg_t val_reg;
  reg_t car_reg;
  reg_t cdr_reg;
  reg_t func_body_reg;
  reg_t func_args_reg;
  reg_t func_env_reg;

  always_comb begin
    fetch_state.next   = fetch_state.current;
    tag_reg.next       = tag_reg.current;
    val_reg.next       = val_reg.current;
    car_reg.next       = car_reg.current;
    cdr_reg.next       = cdr_reg.current;
    func_body_reg.next = func_body_reg.current;
    func_args_reg.next = func_args_reg.current;
    func_env_reg.next  = func_env_reg.current;

    read_enable = 1'b0;
    addr_fetch  = '0;
    fetch_done  = 1'b0;
    fetch_error = 1'b0;

    unique case (fetch_state.current)
      FETCH_IDLE: begin
        if (start_fetch) begin
          addr_fetch = expr.current;
          read_enable = 1'b1;
          fetch_state.next = FETCH_TAG_REQ;
        end
      end

      FETCH_TAG_REQ: fetch_state.next = FETCH_TAG_STORE;
      FETCH_TAG_STORE: begin
        tag_reg.next = read_data;
        addr_fetch = expr.current + 1;
        read_enable = 1'b1;
        unique case (read_data)
          lisp::TYPE_NUMBER:    fetch_state.next = FETCH_VAL_REQ;
          lisp::TYPE_CONS:      fetch_state.next = FETCH_CONS_CAR_REQ;
          lisp::TYPE_FUNC_PRIM: fetch_state.next = FETCH_FUNC_BODY_REQ;
          default:              fetch_state.next = FETCH_ERR;
        endcase
      end

      FETCH_VAL_REQ: fetch_state.next = FETCH_VAL_STORE;
      FETCH_VAL_STORE: begin
        val_reg.next = read_data;
        fetch_state.next = FETCH_DONE;
      end

      FETCH_CONS_CAR_REQ: fetch_state.next = FETCH_CONS_CAR_STORE;
      FETCH_CONS_CAR_STORE: begin
        car_reg.next = read_data;
        addr_fetch = expr.current + 2;
        read_enable = 1'b1;
        fetch_state.next = FETCH_CONS_CDR_REQ;
      end

      FETCH_CONS_CDR_REQ: fetch_state.next = FETCH_CONS_CDR_STORE;
      FETCH_CONS_CDR_STORE: begin
        cdr_reg.next = read_data;
        fetch_state.next = FETCH_DONE;
      end

      FETCH_FUNC_BODY_REQ: fetch_state.next = FETCH_FUNC_BODY_STORE;
      FETCH_FUNC_BODY_STORE: begin
        func_body_reg.next = read_data;
        if (tag_reg.current == lisp::TYPE_FUNC_PRIM) begin
          fetch_state.next = FETCH_DONE;
        end else begin
          addr_fetch = expr.current + 2;
          read_enable = 1'b1;
          fetch_state.next = FETCH_FUNC_ARGS_REQ;
        end
      end

      FETCH_FUNC_ARGS_REQ: fetch_state.next = FETCH_FUNC_ARGS_STORE;
      FETCH_FUNC_ARGS_STORE: begin
        func_args_reg.next = read_data;
        addr_fetch = expr.current + 3;
        read_enable = 1'b1;
        fetch_state.next = FETCH_FUNC_ENV_REQ;
      end

      FETCH_FUNC_ENV_REQ: fetch_state.next = FETCH_FUNC_ENV_STORE;
      FETCH_FUNC_ENV_STORE: begin
        func_env_reg.next = read_data;
        fetch_state.next = FETCH_DONE;
      end

      FETCH_DONE: begin
        fetch_done = 1'b1;
        fetch_state.next = FETCH_IDLE;
      end

      FETCH_ERR: begin
        fetch_error = 1'b1;
        fetch_state.next = FETCH_ERR;
      end

      default: fetch_state.next = FETCH_ERR;
    endcase
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      fetch_state.current   <= FETCH_IDLE;
      tag_reg.current       <= 'h0;
      val_reg.current       <= 'h0;
      car_reg.current       <= 'h0;
      cdr_reg.current       <= 'h0;
      func_body_reg.current <= 'h0;
      func_args_reg.current <= 'h0;
      func_env_reg.current  <= 'h0;
    end else begin
      fetch_state.current   <= fetch_state.next;
      tag_reg.current       <= tag_reg.next;
      val_reg.current       <= val_reg.next;
      car_reg.current       <= car_reg.next;
      cdr_reg.current       <= cdr_reg.next;
      func_body_reg.current <= func_body_reg.next;
      func_args_reg.current <= func_args_reg.next;
      func_env_reg.current  <= func_env_reg.next;
    end
  end

  //────────────────────────────────────────────────────────────
  // Memory WRITE FSM Logic
  //────────────────────────────────────────────────────────────
  logic [lisp::addr_width-1:0] heap_ptr;
  logic want_push_clink;
  logic write_done, write_error;

  logic [lisp::data_width-1:0] clink_return_state;

  typedef enum {
    WRITE_IDLE,
    WRITE_PUSH_CLINK_RETURN,
    WRITE_PUSH_CLINK_FUNC,
    WRITE_PUSH_CLINK_ARGS,
    WRITE_PUSH_CLINK_PREV,
    WRITE_DONE,
    WRITE_ERR
  } write_state_t;

  struct packed {
    write_state_t current;
    write_state_t next;
  } write_state;

  always_comb begin
    write_state.next = write_state.current;
    write_done   = 1'b0;
    write_error  = 1'b0;
    write_enable = 1'b0;
    write_data   = 'h0;

    unique case (write_state.current)
      WRITE_IDLE: begin
        if (want_push_clink) begin
          write_data = lisp::TYPE_CLINK_HEADER;
          write_enable = 1'b1;
          write_state.next = WRITE_PUSH_CLINK_RETURN;
        end
      end

      WRITE_PUSH_CLINK_RETURN: begin
        write_data = clink_return_state;
        write_enable = 1'b1;
        write_state.next = WRITE_PUSH_CLINK_FUNC;
      end

      WRITE_PUSH_CLINK_FUNC: begin
        // Push car reg as our func because we are evaulating a list like:
        // (car (cons 1 2))
        write_data = car_reg.current;
        write_enable = 1'b1;
        write_state.next = WRITE_PUSH_CLINK_ARGS;
      end

      WRITE_PUSH_CLINK_ARGS: begin
        // See above comment for why this is cdr
        write_data = cdr_reg.current;
        write_enable = 1'b1;
        write_state.next = WRITE_PUSH_CLINK_PREV;
      end

      WRITE_PUSH_CLINK_PREV: begin
        write_data = clink.current;
        write_enable = 1'b1;
        write_state.next = WRITE_DONE;
      end

      WRITE_DONE: begin
        write_done = 1'b1;
        write_state.next = WRITE_IDLE;
      end

      WRITE_ERR: write_error = 1'b1;

      default: write_state.next = WRITE_ERR;
    endcase
  end

  always_ff @(posedge clk) begin
    if (rst) begin
      // Setting this to some "large" number for now.
      // If our ROM ever goes beyond 'h50, update to 'h100
      heap_ptr <= 'h50;
      write_state.current = WRITE_IDLE;
    end else begin
      write_state.current <= write_state.next;

      if (write_enable) heap_ptr = heap_ptr + 1;
    end
  end


  logic [lisp::addr_width-1:0] addr_in;
  always_comb begin
    if (read_enable) addr_in = addr_fetch;
    else if (write_enable) addr_in = heap_ptr;
    else addr_in = '0;
  end

  memory_controller #(
    .ADDR_WIDTH(lisp::addr_width),
    .DATA_WIDTH(lisp::data_width)
  ) mem (
    .clk(clk),
    .rst(rst),
    .boot_done(boot_done),
    .addr(addr_in),
    .read_enable(read_enable),
    .write_enable(write_enable),
    .write_data(write_data),
    .read_data(read_data),
    .memory_error(mem_error)
  );

  //────────────────────────────────────────────────────────────
  // Combinational FSM Logic
  //────────────────────────────────────────────────────────────
  struct packed {
    lisp::state_t current;
    lisp::state_t next;
  } state;

  logic go_pressed, go_prev;

  logic entering_error_state;
  assign entering_error_state = (state.current != lisp::Error) && (state.next == lisp::Error);

  //────────────────────────────────────────────────────────────
  // Seven-segment display
  //────────────────────────────────────────────────────────────
  logic [15:0] display_value;
  assign display_value = (state.current == lisp::SelectExpr) ? switches : val.current;
  seven_segment ssg (
    .clk(clk),
    .hex(display_value),
    .error(state.current == lisp::Error),
    .error_code(error_code_reg),
    .cathodes(cathodes),
    .anodes(anodes)
  );

  always_comb begin
    state.next = state.current;
    expr.next  = expr.current;
    val.next   = val.current;
    clink.next = clink.current;

    start_fetch = 1'b0;
    want_push_clink = 1'b0;

    clink_return_state = 'h0;

    leds = 16'b0000;
    error_code = NO_ERR;

    unique case (state.current)
      lisp::Boot: begin
        if (boot_done) state.next = lisp::SelectExpr;
      end

      lisp::SelectExpr: begin
        if (go_pressed) begin
          expr.next = switches;
          state.next = lisp::StartFetch;
        end else begin
          state.next = lisp::SelectExpr;
        end
      end

      lisp::StartFetch: begin
        start_fetch = 1'b1;
        state.next = lisp::MemWait;
      end

      lisp::MemWait: begin
        if (fetch_error) begin
          send_error(FETCH_ERROR);
        end else if (mem_error) begin
          send_error(MEM_ERROR);
        end else if (write_error) begin
          send_error(WRITE_ERROR);
        end else if (fetch_done) begin
          state.next = lisp::Eval;
        end else if (write_done) begin
          // TODO: NEED TO DOUBLE CHECK THIS
          expr.next = car_reg.current;
          state.next = lisp::StartFetch;
        end
      end

      // Determines what kind of thing the expr is, and what to do with it
      lisp::Eval: begin
        unique case (tag_reg.current)
          lisp::TYPE_NUMBER: begin
            val.next = val_reg.current;
            state.next = lisp::Halt;
          end

          lisp::TYPE_CONS: begin
            // TODO: NEED TO DOUBLE CHECK THIS
            // We are looking at a combination (car, cdr)
            // Push a CLINK so we can return to where we currently are
            clink_return_state = lisp::Halt;
            want_push_clink = 1'b1;
            state.next = lisp::MemWait;
          end

          lisp::TYPE_FUNC_PRIM: begin
            // TODO:
            // This is just so I can commit CLINK writing without the
            // system erroring out all the time. Eventually, will probably
            // CLINK pop.
            state.next = lisp::Halt;
          end

          default: send_error(EVAL_ERROR);
        endcase
      end

      lisp::Halt: leds = LED_HALT;

      lisp::Error: begin
        leds = LED_ERROR;
        state.next = lisp::Error;
      end

      default: send_error(STATE_ERROR);
    endcase
  end

  //────────────────────────────────────────────────────────────
  // Clocked State & Continuation Update
  //────────────────────────────────────────────────────────────
  always_ff @(posedge clk) begin
    if (rst) begin
      state.current <= lisp::Boot;
      expr.current  <= 'h0;
      val.current   <= 'h0;
      clink.current <= 'h0;
    end else begin
      state.current <= state.next;
      expr.current  <= expr.next;
      val.current   <= val.next;
      clink.current <= clink.next;

      if (entering_error_state) begin
        error_code_reg <= error_code; //Latch the error
      end
    end
  end

  // For latching the expr user input
  always_ff @(posedge clk) begin
    go_prev    <= btn_start;
    go_pressed <= btn_start & ~go_prev; // Edge detection
  end

endmodule

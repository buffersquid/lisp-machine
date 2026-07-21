#include "eval.h"
#include "cell.h"
#include "memory.h"
#include <stdio.h>
#include <stdlib.h>

// Debug
const char *state_name(state_t s) {
  static const char *names[] = {
#define X(name) #name,
      STATE_LIST
#undef X
  };
  return names[s];
}

// Eval registers
word_t EXPR, VAL, ENV, OP, REMAINING_ARGS;

// memory registers
// MAR (memory address register - holds the address for the pending access)
// MDR (memory data register - holds the word read, or the word to be written)
word_t MAR, MDR;

// State control
state_t STATE, RET;

// Debug
word_t CYCLE_COUNT;

void eval_init(word_t expr) {
  EXPR = expr;
  VAL = nil();
  OP = nil();
  REMAINING_ARGS = nil();
  ENV = nil();

  MAR = MDR = 0;
  RET = S_ERROR;

  STATE = S_EVAL;
  CYCLE_COUNT = 0;
}

void eval_step(void) {
  switch (STATE) {
  case S_MEM_READ:
    MDR = memory[MAR];
    STATE = RET;
    return;

  case S_MEM_WRITE:
    memory[MAR] = MDR;
    STATE = RET;
    return;

  case S_EVAL:
    switch (tag_of(EXPR)) {

    case PRIMITIVE:
      STATE = S_EVAL_SELF;
      return;

    case NIL:
    case FIXNUM:
      STATE = S_EVAL_SELF;
      return;

    case CONS:
      STATE = S_CONS_FETCH_OP;
      return;

    default:
      STATE = S_ERROR;
      return;
    }

  case S_EVAL_SELF: {
    VAL = EXPR;
    STATE = S_RETURN;
    return;
  }

  case S_CONS_FETCH_OP: {
    OP = memory[cons_value(EXPR)];
    STATE = S_CONS_FETCH_ARG;
    return;
  }

  case S_CONS_FETCH_ARG: {
    REMAINING_ARGS = memory[cons_value(EXPR) + 1];
    STATE = S_EVAL_ARG;
    return;
  }

  case S_EVAL_ARG: {
    if (tag_of(REMAINING_ARGS) == NIL) {
      STATE = S_DISPATCH_APPLY;
      return;
    }

    switch (tag_of(OP)) {
    case PRIMITIVE: {
      word_t car = memory[cons_value(REMAINING_ARGS)];
      word_t cdr = memory[cons_value(REMAINING_ARGS) + 1];

      push_frame(FRAME_EVAL_ARG, ENV, OP, nil(), cdr);

      EXPR = car;
      STATE = S_EVAL;
      return;
    }

    default:
      STATE = S_ERROR;
      return;
    }
  }

  // Primitives
  case S_CAR_GOT_ARG:
    MAR = cons_value(MDR); // MDR now holds the (already-evaluated) argument
    RET = S_CAR_GOT_CAR;
    STATE = S_MEM_READ;
    return;

  case S_CAR_GOT_CAR:
    VAL = MDR;
    STATE = S_RETURN;
    return;

  case S_APPLY_PRIMITIVE: {
    switch (primitive_value(OP)) {
    case CAR_OP: {
      MAR = cons_value(REMAINING_ARGS);
      RET = S_CAR_GOT_ARG;
      STATE = S_MEM_READ;
      return;
    }

    case CDR_OP: {
      VAL = memory[cons_value(memory[cons_value(REMAINING_ARGS)]) + 1];
      STATE = S_RETURN;
      return;
    }

    case CONS_OP: {
      word_t car = memory[cons_value(REMAINING_ARGS)];
      word_t cdr = memory[cons_value(memory[cons_value(REMAINING_ARGS) + 1])];

      VAL = cons(car, cdr);

      STATE = S_RETURN;
      return;
    }

    case PLUS_OP: {
      if (tag_of(REMAINING_ARGS) == NIL) {
        VAL = fixnum(0);
        STATE = S_RETURN;
        return;
      }
      VAL = memory[cons_value(REMAINING_ARGS)];
      REMAINING_ARGS = memory[cons_value(REMAINING_ARGS) + 1];
      STATE = S_FOLD_ARGS;
      return;
    }

    default:
      STATE = S_ERROR;
      return;
    }
  }

  case S_FOLD_ARGS: {
    if (tag_of(REMAINING_ARGS) == NIL) {
      STATE = S_RETURN;
      return;
    }
    word_t arg = memory[cons_value(REMAINING_ARGS)];      // car
    word_t next = memory[cons_value(REMAINING_ARGS) + 1]; // cdr

    switch (primitive_value(OP)) {
    case PLUS_OP: {
      VAL = fixnum(fixnum_value(VAL) + fixnum_value(arg));
      break;
    }
    default: {
      STATE = S_ERROR;
      return;
    }
    }

    REMAINING_ARGS = next;
    return; // Stay in S_FOLD_ARGS until done
  }

  // Deliberately a separate state rather than jumping straight to
  // S_APPLY_PRIMITIVE after arg reversal. Reversal is generic — it doesn't
  // know or care what OP is. Once closures exist, OP could be tagged
  // CLOSURE here instead of PRIMITIVE, needing a different next state
  // (e.g. S_APPLY_CLOSURE / param binding). This is the one place that
  // decides, based on OP's tag, so no other state has to hardcode it.
  case S_DISPATCH_APPLY: {
    switch (tag_of(OP)) {
    case PRIMITIVE:
      STATE = S_APPLY_PRIMITIVE;
      return;

    default:
      STATE = S_ERROR;
      return;
    }
  }

  // Evaluated args accumulate in reverse order (each new result is consed
  // onto the front — O(1), but backwards). Rather than build a second list
  // via cons() (which would allocate N cells, all instant garbage, and add
  // GC pressure before GC even exists), we reverse in place: an nreverse,
  // walking the list and flipping each cell's cdr to point backward.
  //
  // Register reuse during this state (safe only because both are dead
  // here — nothing reads EXPR or VAL between S_RETURN's jump into this
  // state and S_DISPATCH_APPLY):
  //   REMAINING_ARGS = curr  (list still being consumed)
  //   EXPR           = prev  (result being built, correct order so far)
  //   VAL            = next  (one-cell lookahead, so we don't lose the
  //                           rest of the list after overwriting its cdr)
  //
  // If a future change makes something read EXPR/VAL in this window,
  // this reuse breaks — re-derive dead-register safety before touching it.
  case S_REVERSE_ARGS: {
    if (tag_of(REMAINING_ARGS) == NIL) {
      REMAINING_ARGS = EXPR;
      STATE = S_DISPATCH_APPLY;
      return;
    }
    VAL = memory[cons_value(REMAINING_ARGS) + 1];
    memory[cons_value(REMAINING_ARGS) + 1] = EXPR;
    EXPR = REMAINING_ARGS;
    REMAINING_ARGS = VAL;
    return;
  }

  case S_RETURN: {
    if (stack_empty()) {
      STATE = S_DONE;
      return;
    }

    word_t frame_type, arg_a, arg_b, arg_c;
    pop_frame(&frame_type, &ENV, &arg_a, &arg_b, &arg_c);

    switch (frame_type) {
    case FRAME_EVAL_ARG: {
      OP = arg_a;
      word_t evaled_args = cons(VAL, arg_b);

      if (tag_of(arg_c) == NIL) {
        REMAINING_ARGS = evaled_args;

        // We can reuse these, as they are dead registers for now
        EXPR = nil();
        VAL = nil();

        STATE = S_REVERSE_ARGS;
        return;
      } else {
        word_t car = memory[cons_value(arg_c)];
        word_t cdr = memory[cons_value(arg_c) + 1];

        push_frame(FRAME_EVAL_ARG, ENV, OP, evaled_args, cdr);

        EXPR = car;
        STATE = S_EVAL;
        return;
      }
    }

    default:
      STATE = S_ERROR;
      return;
    }
  }

  case S_DONE:
  case S_ERROR: {
    return;
  }
  }
}

static step_hook_t step_hook = NULL;
void eval_set_step_hook(step_hook_t hook) { step_hook = hook; }

word_t eval_run(word_t expr) {
  eval_init(expr);

  if (step_hook) {
    step_hook();
  }

  while (STATE != S_DONE && STATE != S_ERROR) {
    eval_step();
    CYCLE_COUNT++;
    if (step_hook) {
      step_hook();
    }
  }
  if (STATE == S_ERROR) {
    fprintf(stderr, "An error occured\n");
    exit(1);
  }
  return VAL;
}

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

word_t EXPR, VAL, ENV;
word_t OP, ARG_EXPR; // OP/ARG_EXPR must be saved to a stack frame before any
                     // nested S_EVAL, since a recursive eval will clobber them
state_t STATE;
word_t CYCLE_COUNT;

void eval_init(word_t expr) {
  EXPR = expr;
  VAL = nil();
  OP = nil();
  ARG_EXPR = nil();

  STATE = S_EVAL;
  CYCLE_COUNT = 0;
}

void eval_step(void) {
  switch (STATE) {
  case S_EVAL:
    switch (tag_of(EXPR)) {
    case PRIMITIVE:
      STATE = S_EVAL_SELF;
      return;
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
  case S_EVAL_SELF:
    VAL = EXPR;
    STATE = S_RETURN;
    return;
  case S_CONS_FETCH_OP:
    OP = memory[cons_value(EXPR)];
    STATE = S_CONS_FETCH_ARG;
    return;
  case S_CONS_FETCH_ARG:
    ARG_EXPR = memory[cons_value(EXPR) + 1];
    STATE = S_CHECK_OP_TAG;
    return;
  case S_CHECK_OP_TAG:
    if (tag_of(OP) == PRIMITIVE) {
      STATE = S_APPLY_PRIMITIVE;
    } else {
      STATE = S_ERROR;
    }
    return;
  case S_APPLY_PRIMITIVE:
    switch (primitive_value(OP)) {
    case CAR:
      STATE = S_PRIM_CAR;
      return;
    case CDR:
      STATE = S_PRIM_CDR;
      return;
    default:
      STATE = S_ERROR;
      return;
    }
  case S_PRIM_CAR:
    VAL = memory[cons_value(ARG_EXPR)];
    STATE = S_RETURN;
    return;

  case S_PRIM_CDR:
    VAL = memory[cons_value(ARG_EXPR) + 1];
    STATE = S_RETURN;
    return;
  case S_RETURN:
    if (stack_empty()) {
      STATE = S_DONE;
    } else {
      STATE = S_ERROR; // We have no frame types defined yet
    }
    return;
  case S_DONE:
    return;
  case S_ERROR:
    return;
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

#include "eval.h"
#include "cell.h"
#include "memory.h"
#include <stdio.h>
#include <stdlib.h>

word_t EXPR, VAL, ENV;
state_t STATE;

void eval_init(word_t expr) {
  EXPR = expr;
  STATE = S_EVAL;
}

void eval_step(void) {
  switch (STATE) {
  case S_EVAL:
    switch (tag_of(EXPR)) {
    case FIXNUM:
      STATE = S_EVAL_SELF;
      return;
    default:
      STATE = S_ERROR; // Ignore anything other than a fixnum for now
      return;
    }
  case S_EVAL_SELF:
    VAL = EXPR;
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
    fprintf(stderr, "An error occured\n");
    exit(1);
  }
}

word_t eval_run(word_t expr) {
  eval_init(expr);
  while (STATE != S_DONE) {
    eval_step();
  }
  return VAL;
}

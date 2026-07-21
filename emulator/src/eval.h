#ifndef EVAL_H
#define EVAL_H
#include "cell.h"

#define STATE_LIST                                                             \
  X(S_MEM_READ)                                                                \
  X(S_MEM_WRITE)                                                               \
  X(S_EVAL)                                                                    \
  X(S_EVAL_SELF)                                                               \
  X(S_CONS_FETCH_OP)                                                           \
  X(S_CONS_FETCH_ARG)                                                          \
  X(S_EVAL_ARG)                                                                \
  X(S_CAR_GOT_ARG)                                                             \
  X(S_CDR_GOT_ARG)                                                             \
  X(S_MEM_RESULT_TO_VAL)                                                       \
  X(S_APPLY_PRIMITIVE)                                                         \
  X(S_REVERSE_ARGS)                                                            \
  X(S_DISPATCH_APPLY)                                                          \
  X(S_FOLD_ARGS)                                                               \
  X(S_RETURN)                                                                  \
  X(S_DONE)                                                                    \
  X(S_ERROR)

typedef enum {
#define X(name) name,
  STATE_LIST
#undef X
} state_t;

const char *state_name(state_t s);

// Defined here so debug.c can use them too
extern word_t EXPR, VAL, ENV, OP, REMAINING_ARGS;
extern word_t MAR, MDR;
extern state_t STATE, RET;

extern word_t CYCLE_COUNT;

word_t eval_run(word_t expr);

// Debug functions
typedef void (*step_hook_t)(void);
void eval_set_step_hook(step_hook_t hook); // pass NULL to disable

#endif

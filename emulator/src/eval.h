#ifndef EVAL_H
#define EVAL_H
#include "cell.h"

typedef enum { S_EVAL, S_EVAL_SELF, S_RETURN, S_DONE, S_ERROR } state_t;

void eval_init(word_t expr);
void eval_step(void);
word_t eval_run(word_t expr);

#endif

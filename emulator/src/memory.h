#ifndef MEMORY_H
#define MEMORY_H
#include "cell.h" // or wherever word_t lives now

#define MEMORY_SIZE 1024

typedef enum { FRAME_EVAL_OP } frame_type_t;

extern word_t memory[MEMORY_SIZE];
extern word_t heap_free, stack_free;

void mem_init(void);
word_t alloc(uint32_t n_words); // bump-allocate n words, return start address

word_t push_frame(word_t frame_type, word_t saved_env, word_t arg_a,
                  word_t arg_b, word_t arg_c);
void pop_frame(word_t *frame_type, word_t *saved_env, word_t *arg_a,
               word_t *arg_b, word_t *arg_c);
int stack_empty(void);

#endif

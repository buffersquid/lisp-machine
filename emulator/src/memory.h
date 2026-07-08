#ifndef MEMORY_H
#define MEMORY_H
#include "cell.h" // or wherever word_t lives now

#define MEMORY_SIZE (1U << (sizeof(word_t) * 8 - 2))

extern word_t memory[MEMORY_SIZE];
extern word_t heap_free, stack_free;

void mem_init(void);
word_t alloc(uint32_t n_words); // bump-allocate n words, return start address
#endif

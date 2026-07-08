#include "memory.h"
#include <stdlib.h>

word_t memory[MEMORY_SIZE];
word_t heap_free, stack_free;

void mem_init(void) {
  heap_free = 0;
  stack_free = MEMORY_SIZE - 1;
}

static void check_memory(void) {
  if (heap_free >= stack_free)
    exit(1);
  if (heap_free >= MEMORY_SIZE)
    exit(1);
}

word_t alloc(uint32_t n_words) {
  check_memory();
  word_t loc = heap_free;
  heap_free += n_words;
  return loc;
}

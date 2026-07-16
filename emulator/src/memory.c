#include "memory.h"
#include <stdio.h>
#include <stdlib.h>

word_t memory[MEMORY_SIZE];
word_t heap_free, stack_free;

// Debug
const char *frame_type_name(frame_type_t s) {
  static const char *names[] = {
#define X(name) #name,
      FRAME_TYPE_LIST
#undef X
  };
  return names[s];
}

void mem_init(void) {
  heap_free = 0;
  stack_free = MEMORY_SIZE - 1;
}

static void check_memory(void) {
  if (heap_free >= stack_free) {
    fprintf(stderr, "heap pointer > stack pointer\n");
    exit(1);
  }
  if (heap_free >= MEMORY_SIZE) {
    fprintf(stderr, "heap pointer > MEMORY_SIZE\n");
    exit(1);
  }
}

word_t alloc(uint32_t n_words) {
  check_memory();
  word_t loc = heap_free;
  heap_free += n_words;
  return loc;
}

word_t push_frame(word_t frame_type, word_t saved_env, word_t arg_a,
                  word_t arg_b, word_t arg_c) {
  stack_free -= 5;
  check_memory();
  memory[stack_free + 0] = frame_type;
  memory[stack_free + 1] = saved_env;
  memory[stack_free + 2] = arg_a;
  memory[stack_free + 3] = arg_b;
  memory[stack_free + 4] = arg_c;
  return stack_free;
}

void pop_frame(word_t *frame_type, word_t *saved_env, word_t *arg_a,
               word_t *arg_b, word_t *arg_c) {
  *frame_type = memory[stack_free + 0];
  *saved_env = memory[stack_free + 1];
  *arg_a = memory[stack_free + 2];
  *arg_b = memory[stack_free + 3];
  *arg_c = memory[stack_free + 4];
  stack_free += 5;
}

int stack_empty(void) { return stack_free == MEMORY_SIZE - 1; }

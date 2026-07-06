// (+ 2 3)
// ((lambda (x) (+ x 1)) 5)
// Until I can run the above procs, NO BUILDING A REPL!

#include <stdint.h>

typedef uint32_t word_t;

// number of bits in a type
#define BITS_OF(type) (sizeof(type) * 8)
// MEM_SIZE = 2^(number of bits in word - 2)
#define HEAP_SIZE (1U << (BITS_OF(word_t) - 2))

typedef struct {
  word_t car, cdr;
} cons_cell_t;

typedef struct {
  char name[16]; // arbitrary string size for now
  word_t value;
  word_t function;
} symbol_t;

cons_cell_t heap[HEAP_SIZE];

int main() {}

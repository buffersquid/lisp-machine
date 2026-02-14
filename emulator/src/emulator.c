// (+ 2 3)
// ((lambda (x) (+ x 1)) 5)
// Until I can run the above procs, NO BUILDING A REPL!

#include <stdint.h>
#include <stdio.h>

typedef uint16_t word;

// number of bits in a type
#define BITS_OF(type) (sizeof(type) * 8)
// MEM_SIZE = 2^(number of bits in word - 2)
#define MEM_SIZE (1U << (BITS_OF(word) - 2))

word memory[MEM_SIZE];
word *heap_ptr = memory;

typedef enum TagValue { NIL, CONS, SYMBOL, FIXNUM } TagValue;

// Util functions
word extract_payload(word w) { return w >> 2; }

// Allocator functions
word fixnum(word number) { return (number << 2) | FIXNUM; }
word cons(word carVal, word cdrVal) {
  word *addr = heap_ptr;
  heap_ptr += 2;
  addr[0] = carVal;
  addr[1] = cdrVal;
  return ((word)(addr - memory) << 2) | CONS;
}

int main() {
  word cell = cons(fixnum(2), fixnum(10));

  printf("cons CAR = %d\n", extract_payload(memory[extract_payload(cell)]));
  printf("cons CDR = %d\n", extract_payload(memory[extract_payload(cell) + 1]));

  return 0;
}

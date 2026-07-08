// (+ 2 3)
// ((lambda (x) (+ x 1)) 5)
// Until I can run the above procs, NO BUILDING A REPL!

#include "cell.h"
#include "memory.h"

#include <assert.h>
#include <stdint.h>
#include <stdio.h>

int main() {
  mem_init();
  word_t six = fixnum(6);
  word_t seven = fixnum(7);
  word_t c = cons(six, seven);
  printf("%d\n", fixnum_value(six));
  printf("%d\n", fixnum_value(seven));
  printf("%d\n", cons_value(c));
}

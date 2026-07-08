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
  word_t c = cons(primitive(CAR), cons(fixnum(6), fixnum(7)));
  printf("%d\n", cons_value(c));
}

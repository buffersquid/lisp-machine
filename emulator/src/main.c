// (+ 2 3)
// ((lambda (x) (+ x 1)) 5)
// Until I can run the above procs, NO BUILDING A REPL!

#include "cell.h"
#include "eval.h"
#include "memory.h"

#include <stdio.h>

int main(void) {
  mem_init();
  // (car (6 . 7)) -> 6
  word_t expr = cons(primitive(CAR), cons(fixnum(6), fixnum(7)));
  word_t result = eval_run(expr);
  printf("%d\n", fixnum_value(result));
}

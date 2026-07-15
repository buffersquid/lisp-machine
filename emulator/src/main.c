// (+ 2 3)
// ((lambda (x) (+ x 1)) 5)
// Until I can run the above procs, NO BUILDING A REPL!

#include "cell.h"
#include "debug.h"
#include "eval.h"
#include "memory.h"

#include <stdio.h>
#include <string.h>

int main(int argc, char **argv) {
  mem_init();
  if (argc > 1 &&
      (strcmp(argv[1], "--debug") == 0 || strcmp(argv[1], "-d") == 0)) {
    printf("[ALERT] running in debug mode\n");
    eval_set_step_hook(debug_step_hook);
  }
  // (car (6 . 7)) -> 6
  word_t expr = cons(primitive(OP_CAR), cons(fixnum(6), fixnum(7)));
  word_t result = eval_run(expr);
  print_lisp(result);
  printf("\n");
}

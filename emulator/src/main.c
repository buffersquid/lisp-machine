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
  // (+ 1 (car (cons 2 3)) (+ 4 5 6) 7 (cdr (cons 66 77)))
  word_t expr0 = cons(
      primitive(CAR_OP),
      cons(cons(primitive(CONS_OP), cons(fixnum(2), cons(fixnum(3), nil()))),
           nil()));
  word_t expr1 = cons(primitive(PLUS_OP),
                      cons(fixnum(4), cons(fixnum(5), cons(fixnum(6), nil()))));
  word_t expr2 = cons(
      primitive(CDR_OP),
      cons(cons(primitive(CONS_OP), cons(fixnum(66), cons(fixnum(77), nil()))),
           nil()));
  word_t expr =
      cons(primitive(PLUS_OP),
           cons(fixnum(1),
                cons(expr0, cons(expr1, cons(fixnum(7), cons(expr2, nil()))))));
  word_t result = eval_run(expr);
  print_lisp(result);
  printf("\n");
}

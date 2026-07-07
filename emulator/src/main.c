// (+ 2 3)
// ((lambda (x) (+ x 1)) 5)
// Until I can run the above procs, NO BUILDING A REPL!

#include "cell.h"

#include <assert.h>
#include <stdint.h>
#include <stdio.h>

int main() {
  word_t six = fixnum(6);
  printf("%d\n", fixnum_value(six));
}

#include "debug.h"
#include "eval.h"
#include "memory.h"
#include <stdio.h>
#include <stdlib.h>

static int running_free = 0; // true after 'c' — skip pausing until stopped
static int help_shown = 0;

void print_lisp(word_t w) {
  switch (tag_of(w)) {
  case FIXNUM:
    printf("%u", fixnum_value(w));
    return;
  case PRIMITIVE:
    printf("%s", primitive_name((primitive_t)payload_of(w)));
    return;
  case NIL:
    printf("nil");
    return;
  case CONS: {
    word_t addr = cons_value(w);
    printf("(");
    print_lisp(memory[addr]); // car
    printf(" . ");
    print_lisp(memory[addr + 1]); // cdr
    printf(")");
    return;
  }
  }
}

static void print_registers(void) {
  printf("(%u) NEXT STATE = %s\n", CYCLE_COUNT, state_name(STATE));

  printf("  EXPR     [%s 0x%07X] = ", tag_name(tag_of(EXPR)), payload_of(EXPR));
  print_lisp(EXPR);
  printf("\n");

  printf("  ENV      [%s 0x%07X] = ", tag_name(tag_of(ENV)), payload_of(ENV));
  print_lisp(ENV);
  printf("\n");

  printf("  VAL      [%s 0x%07X] = ", tag_name(tag_of(VAL)), payload_of(VAL));
  print_lisp(VAL);
  printf("\n");

  printf("  OP       [%s 0x%07X] = ", tag_name(tag_of(OP)), payload_of(OP));
  print_lisp(OP);
  printf("\n");

  printf("  REM_ARGS [%s 0x%07X] = ", tag_name(tag_of(REMAINING_ARGS)),
         payload_of(REMAINING_ARGS));
  print_lisp(REMAINING_ARGS);
  printf("\n");
}

static void print_heap(void) {
  printf("heap [0 .. %u):\n", heap_free);
  for (word_t i = 0; i < heap_free; i++) {
    printf("  0x%04X: [%s 0x%07X] = ", i, tag_name(tag_of(memory[i])),
           payload_of(memory[i]));
    print_lisp(memory[i]);
    printf("\n");
  }
}

static void print_stack(void) {
  printf("stack [0x%04X .. top):\n", stack_free);
  for (word_t i = stack_free; i < MEMORY_SIZE - 1; i += 5) {
    printf("  frame @0x%04X: type=%s, env=", i, frame_type_name(memory[i]));
    print_lisp(memory[i + 1]);
    printf(" a=");
    print_lisp(memory[i + 2]);
    printf(" b=");
    print_lisp(memory[i + 3]);
    printf(" c=");
    print_lisp(memory[i + 4]);
    printf("\n");
  }
}

static void print_help(void) {
  printf("[n]ext step  [p]rint registers  [m]emory dump  [c]ontinue  [q]uit\n");
}

void debug_step_hook(void) {
  print_registers();

  if (running_free) {
    return; // 'c' was pressed earlier — don't pause anymore
  }

  if (!help_shown) {
    print_help();
    help_shown = 1;
  }

  for (;;) {
    printf("> ");
    int ch = getchar();
    while (ch != '\n' && ch != EOF && getchar() != '\n')
      ;

    switch (ch) {
    case 'n':
    case '\n':
      return; // advance exactly one step
    case 'c':
      running_free = 1;
      return; // advance freely from now on
    case 'p':
      print_registers();
      continue; // stay in the loop, ask again
    case 'm':
      print_heap();
      print_stack();
      continue;
    case 'q':
      exit(0); // abort entirely
    default:
      print_help();
      continue; // stay in the loop, ask again
    }
  }
}

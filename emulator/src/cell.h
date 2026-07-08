#ifndef CELL_H
#define CELL_H
#include <stdint.h>

typedef uint32_t word_t;
typedef enum {
  CONS,
  FIXNUM,
  SYMBOL,
  CLOSURE,
  PRIMITIVE,
  UNBOUND,
  NIL,
  TRUE
} tag_t;

word_t fixnum(word_t i);
word_t fixnum_value(word_t w);

word_t cons(word_t car, word_t cdr);
word_t cons_value(word_t cons);

#endif

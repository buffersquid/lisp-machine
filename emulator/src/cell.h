#ifndef CELL_H
#define CELL_H
#include <stdint.h>

typedef uint32_t word_t;
typedef enum {
  CONS,
  FIXNUM,
  PRIMITIVE,
  // SYMBOL,
  // CLOSURE,
  // UNBOUND,
  // NIL,
  // TRUE
} tag_t;

typedef enum { CAR, CDR } primitive_t;

tag_t tag_of(word_t w);

word_t fixnum(word_t i);
word_t fixnum_value(word_t w);

word_t primitive(primitive_t p);
word_t primitive_value(word_t p);

word_t cons(word_t car, word_t cdr);
word_t cons_value(word_t c);

#endif

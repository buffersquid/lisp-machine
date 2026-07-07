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

typedef struct {
  word_t _bits;
} fixnum_t;

fixnum_t fixnum(word_t i);
tag_t fixnum_tag(fixnum_t f);
word_t fixnum_value(fixnum_t f);

#endif

#ifndef CELL_H
#define CELL_H
#include <stdint.h>

typedef uint32_t word_t;

#define TAG_LIST                                                               \
  X(CONS)                                                                      \
  X(FIXNUM)                                                                    \
  X(PRIMITIVE)                                                                 \
  X(NIL)

typedef enum {
#define X(name) name,
  TAG_LIST
#undef X
} tag_t;

const char *tag_name(tag_t t);

#define PRIMITIVE_LIST                                                         \
  X(CAR_OP)                                                                    \
  X(CDR_OP)                                                                    \
  X(CONS_OP)

typedef enum {
#define X(name) name,
  PRIMITIVE_LIST
#undef X
} primitive_t;

const char *primitive_name(primitive_t t);

tag_t tag_of(word_t w);
word_t payload_of(word_t w);

word_t nil(void);

word_t fixnum(word_t i);
word_t fixnum_value(word_t w);

word_t primitive(primitive_t p);
word_t primitive_value(word_t p);

word_t cons(word_t car, word_t cdr);
word_t cons_value(word_t c);

#endif

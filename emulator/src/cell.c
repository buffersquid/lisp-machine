#include "cell.h"
#include "memory.h"
#include <assert.h>

#define TAG_SIZE 4
#define PAYLOAD_SIZE (sizeof(word_t) * 8 - TAG_SIZE)
#define PAYLOAD_MASK 0x0FFFFFFF

tag_t tag_of(word_t w) { return (tag_t)(w >> PAYLOAD_SIZE); }
static word_t payload_of(word_t w) { return w & PAYLOAD_MASK; }

word_t fixnum(word_t i) {
  return (FIXNUM << PAYLOAD_SIZE) | (i & PAYLOAD_MASK);
}
word_t fixnum_value(word_t w) {
  assert(tag_of(w) == FIXNUM);
  return payload_of(w);
}

word_t primitive(primitive_t p) {
  return (PRIMITIVE << PAYLOAD_SIZE | ((word_t)p & PAYLOAD_MASK));
}
word_t primitive_value(word_t p) {
  assert(tag_of(p) == PRIMITIVE);
  return payload_of(p);
}

word_t cons(word_t car, word_t cdr) {
  word_t loc = alloc(2);
  memory[loc] = car;
  memory[loc + 1] = cdr;
  return (CONS << PAYLOAD_SIZE) | loc;
}
word_t cons_value(word_t c) {
  assert(tag_of(c) == CONS);
  return payload_of(c);
}

#include "cell.h"

#define TAG_SIZE 4
#define PAYLOAD_SIZE (sizeof(word_t) * 8 - TAG_SIZE)

static tag_t tag_of(word_t w) { return (tag_t)(w >> PAYLOAD_SIZE); }
static word_t payload_of(word_t w) { return w & 0x0FFFFFFF; }

fixnum_t fixnum(word_t i) {
  return (fixnum_t){(FIXNUM << PAYLOAD_SIZE) | (i & 0x0FFFFFFF)};
}
tag_t fixnum_tag(fixnum_t f) { return tag_of(f._bits); }
word_t fixnum_value(fixnum_t f) { return payload_of(f._bits); }

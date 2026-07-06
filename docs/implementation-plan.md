# LISP Machine Hardware Implementation Plan

## Overview

This isn't a general CPU that happens to run a lisp interpreter. It should be a machine whose native data type is a cons cell and whose native instruction cycle is `eval/apply`.

This means that the memory map isn't code + data like regular memory maps. It's a heap of tagged cells and a few registers that drive a fundamental eval loop. So everything (PROG ROM, the stack, the env, everything) is just more cons cells on top of more cons cells.

## Design of a Cell

Classic lisp machines used tagged words, so I suppose we will too.

```
[ TAG (n bits) | CAR/value (wordsize - n bits)]
[ TAG (n bits) | CDR       (wordsize - n bits)]
```

For our starting architecture, we will use **32 bits**, with a **4 bit tag** and a **28 bit payload**. This gives us `256M` cells to work with.

### Tags

|    Tag    |   Description  | Shape | Stride |
| --------- | -------------- | ----- | ------ |
| CONS      | Index/pointer to a cons cell | Fixed | 2 (car, cdr) |
| FIXNUM    | Immediate integer | Immediate | - |
| SYMBOL    | Points to structure in memory | fixed | 2 (value, function) |
| CLOSURE   | Points to a structure in memory | fixed | 3 (params, body, env) |
| NIL       | Payload unused | Immediate | - |
| TRUE      | Payload unused | Immediate | - |
| PRIMITIVE | Opcode of built-in primitive | Immediate | - (+, -, car, cdr, cons, eq?, etc) |
| UNBOUND   | No definition | Immediate | - |

## Memory Map

While the cool thing about this architecture is that we are muddling code and data, we still want to define a memory map for ease of understanding. It could look like:

|     Region    | Contents |
| ------------- | -------- |
| 0x0000 growing downwards | Heap     |
| 0xFFFF growing upwards | Control stack (continuation frames for EVAL/APPLY) |

When the pointer to the heap and the pointer to the stack pass each other, we are out of memory.

### Heap

In the heap, data exists as untyped. This means that the reference to that data determines the interpretation of the data.

Data exists in 2 ways:

1) Fixed-shape
2) Variable-shape

#### Fixed-shape

The tag tells the allocator and the garbage collector (GC) the size of the object, as the size is always the same. For example, a `CONS` is always 2 words (`CAR`, and `CDR`). A `CLOSURE` is always 3 words (`params`, `body`, and `env`)

#### Variable-shape
Some types genuinely need a runtime length because the size depends on the value. A 3-character string and a 300-character string can't both be "always N words." For these, the first word of the heap object is a header encoding the length. The payload follows immediately after:
```

[ word 0 ] HEADER: [ TAG (4 bits) | LENGTH (28 bits) ]
[ word 1 ] payload word 0
[ word 2 ] payload word 1
...
[ word 1+LENGTH ] payload word LENGTH-1
```

So a string "hi" at address 0x1020:
```
0x1020: STRING-HEADER : 2      (length = 2 characters)
0x1021: CHAR : 'h'
0x1022: CHAR : 'i'
```

Pointer to it: `STRING:0x1020`
Accessing character N: `read word at 0x1020+1+N`

### Stack

We are going to use a frame system to hold stack data as we evaluate code.

Every frame is 5 words, so `SP` always moves in multiples of 5.

```
[SP-0]: frame_type  - what to do when VAL comes back
[SP-1]: saved_env   - ENV register at the time of the push (to be restored after return)
[SP-2]: arg_a       - meaning depends on frame_type
[SP-3]: arg_b       - meaning depends on frame_type
[SP-4]: arg_c       - meaning depends on frame_type
```

For `frame_type`, we can use `FIXNUM:n` for the type and just keep a map in hardware. For example:

| frame_type | name | arg_a | arg_b | arg_c |
| --------------- | --------------- | --------------- | --------------- | --------------- |
| FIXNUM:0 | EVAL_OP | UNBOUND:0 (op unknown) | NIL:0 (no args yet) | remaining arg list |
| FIXNUM:1 | EVAL_ARG | op (tagged word) | evaled_args so far | remaining arg list |





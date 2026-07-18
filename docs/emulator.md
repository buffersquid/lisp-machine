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

Implemented so far (`cell.h`):

|    Tag    |   Description  | Shape | Stride |
| --------- | -------------- | ----- | ------ |
| CONS      | Index/pointer to a cons cell | Fixed | 2 (car, cdr) |
| FIXNUM    | Immediate integer | Immediate | - |
| PRIMITIVE | Opcode of built-in primitive | Immediate | - (car, cdr, cons so far) |
| NIL       | Payload unused | Immediate | - |

Settled, not yet implemented:

|    Tag      |   Description  | Shape | Stride |
| ----------- | -------------- | ----- | ------ |
| T           | Payload unused | Immediate | - |
| UNBOUND     | No definition | Immediate | - |
| SYMBOL      | Points to structure in memory | Fixed | 2 (value, function) |
| CLOSURE     | Points to a structure in memory | Fixed | 3 (params, body, env) |
| FLOAT       | Points to a structure in memory | Fixed | 2 |
| STRING      | Points to a length-prefixed structure in memory | Variable | header + N |
| VECTOR      | Points to a length-prefixed structure in memory | Variable | header + N |
| GC-FORWARD  | Forwarding pointer left behind by GC | Fixed | 1 |

### Primitives

Implemented so far (`PRIMITIVE_LIST` in `cell.h`):

| Primitive | Behavior |
| --------- | -------- |
| CAR_OP    | Returns the car of its single cons argument |
| CDR_OP    | Returns the cdr of its single cons argument |
| CONS_OP   | Conses its two evaluated arguments together — treated as a callable primitive rather than special-cased literal data, so no `quote` mechanism is needed for the MVP |

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

For `frame_type`, we can use `FIXNUM:n` for the type and just keep a map in hardware.

Implemented so far (`FRAME_TYPE_LIST` in `memory.h`):

| frame_type | name | arg_a | arg_b | arg_c |
| --------------- | --------------- | --------------- | --------------- | --------------- |
| FIXNUM:0 | EVAL_ARG | op (tagged word) | evaled_args so far | remaining arg list |

Note: in the MVP, `OP` (the operator position of a combination) is read directly out of the cons cell's car rather than evaluated — it's assumed to already be a `PRIMITIVE`. That's why there's no `EVAL_OP` frame yet; evaluating the operator position (e.g. to look up a symbol bound to a closure) is deferred.

Deferred frame types, to be added alongside their corresponding evaluator states:

| frame_type | name | purpose |
| --------------- | --------------- | --------------- |
| EVAL_OP  | Evaluate the operator position of a combination before applying it (needed once symbols/closures exist) |
| EVAL_IF  | Resume after evaluating an `if` condition |
| EVAL_SEQ | Resume mid-way through a sequence of body expressions (e.g. closure bodies, `begin`) |
| EVAL_DEF | Resume after evaluating the value expression of a `define` |
| EVAL_SET | Resume after evaluating the value expression of a `set!` |

## Evaluator

The evaluator is an explicit finite-state machine: each state maps to roughly one register operation or one memory access, matching what a clock tick would do in the eventual SystemVerilog implementation. There is no recursive C `eval()` call anywhere — control flow that would otherwise be a native call stack is instead pushed/popped as frames on the explicit stack described above.

Registers driving the FSM (`eval.h`): `EXPR`, `VAL`, `ENV`, `OP`, `REMAINING_ARGS`, plus `STATE` and a `CYCLE_COUNT` used for debugging.

States implemented so far (`STATE_LIST` in `eval.h`):

| State | Purpose |
| ----- | ------- |
| S_EVAL | Dispatch on the tag of `EXPR`: self-evaluating vs. a combination to unpack |
| S_EVAL_SELF | Self-evaluating atom (`FIXNUM`, `NIL`, `PRIMITIVE`) — copy `EXPR` into `VAL` |
| S_CONS_FETCH_OP | Read the operator out of the car of `EXPR` into `OP` |
| S_CONS_FETCH_ARG | Read the argument list out of the cdr of `EXPR` into `REMAINING_ARGS` |
| S_EVAL_ARG | Push an `EVAL_ARG` frame for the remaining args, then evaluate the next argument |
| S_APPLY_PRIMITIVE | Dispatch on `primitive_value(OP)` and execute the primitive (`CAR_OP`/`CDR_OP`/`CONS_OP`) |
| S_DISPATCH_APPLY | Single point that dispatches on the tag of `OP` (`PRIMITIVE` today; `CLOSURE` once closures exist) after argument evaluation finishes |
| S_REVERSE_ARGS | In-place `nreverse` of the evaluated-args list (built up backwards, one cons per arg, as an O(1) prepend) before dispatch |
| S_RETURN | Pop a stack frame (if any) and resume the calling context based on `frame_type`; if the stack is empty, evaluation is done |
| S_DONE | Terminal state — `VAL` holds the result |
| S_ERROR | Terminal state — something went wrong (unrecognized tag, unimplemented frame type, etc.) |

`S_EVAL_IF`, `S_EVAL_SEQ`, `S_EVAL_DEF`, `S_EVAL_SET` and their corresponding frame types are deferred past the MVP milestone below.

## Current Implementation Status

Module structure: `cell.c/h` (tagged words), `memory.c/h` (heap/stack), `eval.c/h` (the FSM above), `debug.c/h` (interactive debugger), `main.c` (entry point).

The debugger single-steps the FSM, printing registers (with a recursive `print_lisp`) and dumping heap/stack on demand; it's wired in via a `step_hook` function pointer (`eval_set_step_hook`) so `eval.c` has no reverse dependency on `debug.c`. Free-run mode is available via a `-d`/`--debug` CLI flag.

Self-imposed milestone before building a REPL: evaluate `(+ 2 3)` and `((lambda (x) (+ x 1)) 5)`. Neither is runnable yet — `+`, `SYMBOL`, and `CLOSURE` aren't implemented. `main.c` currently runs `(car (cons 6 7))` as the smallest end-to-end exercise of the combination-evaluation path (fetch op, fetch args, evaluate each arg via `EVAL_ARG` frames, reverse, dispatch, apply).

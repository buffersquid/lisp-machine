CC ?= gcc
CFLAGS ?= -O2 -Wall -Wextra -pedantic -Werror
OUTDIR = bin

TARGET = emulator
SRC := $(wildcard src/*.c)

all: $(OUTDIR)/$(TARGET)

$(OUTDIR)/$(TARGET): $(SRC)
	mkdir -p $(OUTDIR)
	$(CC) $(CFLAGS) -o $@ $^

clean:
	rm -rf $(OUTDIR)

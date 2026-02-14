CC ?= gcc
CFLAGS ?= -O2 -Wall -Wextra -pedantic -Werror
OUTDIR = bin

TARGET = emulator
SRC = src/*

all: $(OUTDIR)/$(TARGET)

$(OUTDIR)/$(TARGET): $(SRC)
	mkdir -p $(OUTDIR)
	$(CC) $(CFLAGS) -o $@ $^

clean:
	rm -f $(OUTDIR)/$(TARGET)

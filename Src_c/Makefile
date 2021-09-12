CC=riscv64-unknown-linux-gnu-gcc
MARCH=rv32i
MABI=ilp32
CFLAGS= -march=$(MARCH) -mabi=$(MABI)
LDFLAGS = -nostartfiles -nostdlib -T my_link.ld

all:main.o main.elf


main.o:my_main.c 
	$(CC) $(CFLAGS) -c -o $@ $^

main.elf: main.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

clean:
	rm -rf *.o *.elf
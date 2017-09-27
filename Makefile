BUILD = $(CC) $(CFLAGS) -g $< -o $@
BUILDSO = $(BUILD) -fPIC -shared

thing: main.o libleak1.so libleak2.so libcheckmalloc.so
	$(BUILD) -L. -lleak1 -lleak2

libleak%.so: leak.c
	$(BUILDSO) -Dleak=leak$*

libcheckmalloc.so: checkmalloc.c
	$(BUILDSO) -ldl

.PHONY: clean run

clean:
	rm -f *.*o thing

run: thing
	gdb -q -x gdb1 ./thing
	gdb -q -x gdb2 ./thing

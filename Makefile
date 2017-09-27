BUILDSO = $(CC) $(CFLAGS) -fPIC -shared -g

thing: main.o libleak1.so libleak2.so libcheckmalloc.so
	$(CC) $(CFLAGS) $(LDFLAGS) $< -o $@ -L. -lleak1 -lleak2

libleak%.so: leak.c
	$(BUILDSO) -Dleak=leak$* $< -o $@

libcheckmalloc.so: checkmalloc.c
	$(BUILDSO) $< -o $@ -ldl

.PHONY: clean run

clean:
	rm -f *.*o thing

run: thing
	LD_LIBRARY_PATH=$$PWD ./thing
	LD_PRELOAD=$$PWD/libcheckmalloc.so LD_LIBRARY_PATH=$$PWD ./thing

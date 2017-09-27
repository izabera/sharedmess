override CFLAGS += -g
BUILD = $(CC) $(CFLAGS) $< -o $@
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
	@echo
	@printf '\033[32m############# RUN WITHOUT CHECKMALLOC #############\033[m\n'
	@echo
	LD_LIBRARY_PATH=. ./thing
	@echo
	@printf '\033[32m############### RUN WITH CHECKMALLOC ##############\033[m\n'
	@echo
	LD_PRELOAD=./libcheckmalloc.so LD_LIBRARY_PATH=. ./thing

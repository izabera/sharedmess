/*
 izabera | is there a way to wrap all the malloc calls from some library that's
         | dynamically linked, without affecting any other malloc call from the
         | rest of the program?
corkmork | You could interpose malloc with a wrapper that on init reads
         | /proc/self/maps (to find the addr range of the library) and call
         | __builtin_return_address(0) to see if the call is originating from
         | the library in question.
corkmork | or hack on ld.so (so it can interpose only one lib) :-p
*/

#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <dlfcn.h>

static size_t liboffsets[100];
static int offsets_i = 0;

void *(*origmalloc)(size_t);

void __attribute__((constructor)) mallocsetup() {
  /*origmalloc = dlsym(RTLD_NEXT, "malloc");*/
  origmalloc = malloc;

  char buf[512];
  FILE *selfmaps = fopen("/proc/self/maps", "r");

  // scan
  while (fgets(buf, sizeof buf, selfmaps)) {
    // match the libs we're looking for
    if (strstr(buf, "leak1")) {
      // parse their addresses
      sscanf(buf, "%lx-%lx", liboffsets+offsets_i, liboffsets+offsets_i+1);
      printf("found leak1 stuff: %lx %lx\n", liboffsets[offsets_i], liboffsets[offsets_i+1]);
      offsets_i += 2;
    }
  }

  fclose(selfmaps);
}




int lookup(void *addr) {
  printf("looking up %p\n", addr);
  for (int i = 0; i < offsets_i; i += 2)
    if ((size_t)addr <= liboffsets[i] && (size_t)addr >= liboffsets[i+1])
      return 1;
  return 0;
}

/*void *malloc(size_t size) {*/
  /*if (lookup(__builtin_return_address(0)))*/
    /*puts("malloc called from leak1");*/
  /*return origmalloc(size);*/
/*}*/

void *malloc(unsigned long);

void leak() { malloc(10); }

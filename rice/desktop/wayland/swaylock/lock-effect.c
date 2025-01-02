#include <stdint.h>
#include <stdlib.h>

static int cmp(uint32_t* a, uint32_t* b) {
	return *a ^ *b;
}

void swaylock_effect(uint32_t* data, int w, int h) {
	qsort(data, w * h, sizeof(*data), cmp);
}

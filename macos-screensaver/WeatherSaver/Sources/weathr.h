#ifndef weathr_h
#define weathr_h

#include <stdbool.h>
#include <stddef.h>

extern int weathr_init(void);
extern void weathr_init_with_location(double lat, double lon, bool metric, const char *city);
extern int weathr_update(void);
extern int weathr_update_if_needed(void);
extern char* weathr_render_frame(void);
extern void weathr_free_string(char *s);

#endif

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

extern int32_t weathr_init(void);
extern void weathr_init_with_location(double lat, double lon, bool metric, const char *city);
extern int32_t weathr_update(void);
extern int32_t weathr_update_if_needed(void);
extern char* weathr_render_frame(void);
extern void weathr_free_string(char *s);
extern size_t weathr_get_width(void);
extern size_t weathr_get_height(void);
extern void weathr_set_location(double lat, double lon);
extern void weathr_set_units(bool metric);
extern void weathr_set_city(const char *city);

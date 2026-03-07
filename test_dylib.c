#include <stdio.h>
#include <stdlib.h>

extern int weathr_init(void);
extern char* weathr_render_frame(void);
extern void weathr_free_string(char* s);

int main() {
    printf("Testing weathr library...\n");
    
    int result = weathr_init();
    printf("weathr_init() = %d\n", result);
    
    char* frame = weathr_render_frame();
    if (frame) {
        printf("Frame received!\n%s\n", frame);
        weathr_free_string(frame);
    } else {
        printf("ERROR: frame is NULL\n");
    }
    
    printf("Done!\n");
    return 0;
}

#include <stdio.h>
#include <stdlib.h>
#include "src/weathr.h"

int main() {
    printf("Starting test...\n");
    
    int result = weathr_init();
    printf("weathr_init() returned: %d\n", result);
    
    char *frame = weathr_render_frame();
    if (frame == NULL) {
        printf("ERROR: weathr_render_frame() returned NULL\n");
        return 1;
    }
    
    printf("Frame received:\n%s\n", frame);
    weathr_free_string(frame);
    
    printf("Test complete!\n");
    return 0;
}

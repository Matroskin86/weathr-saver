#import <ScreenSaver/ScreenSaver.h>
#import "weathr.h"
#import <dlfcn.h>

@interface WeatherSaverView : ScreenSaverView
@end

@implementation WeatherSaverView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        NSLog(@"WeatherSaver: starting...");
        
        // Try to load dylib manually
        NSString *dylibPath = [[NSBundle bundleForClass:[self class]] pathForResource:@"libweathr" ofType:@"dylib"];
        NSLog(@"WeatherSaver: dylib path: %@", dylibPath);
        
        if (dylibPath) {
            void *handle = dlopen([dylibPath UTF8String], RTLD_NOW);
            if (handle) {
                NSLog(@"WeatherSaver: dylib loaded successfully!");
            } else {
                NSLog(@"WeatherSaver: dylib load FAILED: %s", dlerror());
            }
        } else {
            NSLog(@"WeatherSaver: dylib NOT FOUND in bundle!");
        }
        
        // Try calling Rust
        int result = weathr_init();
        NSLog(@"WeatherSaver: weathr_init returned %d", result);
        
        [self setAnimationTimeInterval:0.5];
    }
    return self;
}

- (void)animateOneFrame
{
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect
{
    // Try to call Rust
    char *frame = weathr_render_frame();
    
    if (frame != NULL) {
        // Rust works! GREEN background
        [[NSColor greenColor] setFill];
        NSLog(@"WeatherSaver: Rust works!");
    } else {
        // Rust failed! RED background
        [[NSColor redColor] setFill];
        NSLog(@"WeatherSaver: Rust FAILED");
    }
    NSRectFill(rect);
    
    NSString *text = frame ? [NSString stringWithUTF8String:frame] : @"Rust FAILED";
    if (frame) weathr_free_string(frame);
    
    NSFont *font = [NSFont systemFontOfSize:10];
    NSDictionary *attrs = @{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: [NSColor whiteColor]
    };
    [text drawAtPoint:NSMakePoint(10, 10) withAttributes:attrs];
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

@end

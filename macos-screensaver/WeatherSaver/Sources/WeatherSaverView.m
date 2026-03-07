#import <ScreenSaver/ScreenSaver.h>
#import "weathr.h"

@interface WeatherSaverView : ScreenSaverView
@end

@implementation WeatherSaverView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        NSLog(@"WeatherSaver: initializing...");
        
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
    // Try to call Rust - if it fails, show RED
    char *frame = weathr_render_frame();
    
    if (frame != NULL) {
        // Rust works! GREEN background
        [[NSColor greenColor] setFill];
        NSLog(@"WeatherSaver: Rust works!");
    } else {
        // Rust failed! RED background
        [[NSColor redColor] setFill];
        NSLog(@"WeatherSaver: Rust FAILED - frame is NULL");
    }
    NSRectFill(rect);
    
    // Draw text
    NSString *text = frame ? [NSString stringWithUTF8String:frame] : @"Rust FAILED - no data";
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

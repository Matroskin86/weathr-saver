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
        
        weathr_init();
        
        NSLog(@"WeatherSaver: initialized");
        [self setAnimationTimeInterval:0.1];
    }
    return self;
}

- (void)animateOneFrame
{
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect
{
    // Black background
    [[NSColor blackColor] setFill];
    NSRectFill(rect);
    
    // Get weather frame
    weathr_update_if_needed();
    
    char *frame = weathr_render_frame();
    NSString *text = @"Loading...";
    if (frame != NULL) {
        text = [NSString stringWithUTF8String:frame];
        weathr_free_string(frame);
    }
    
    // Draw text
    NSFont *font = [NSFont fontWithName:@"Menlo" size:10];
    if (!font) {
        font = [NSFont systemFontOfSize:10];
    }
    
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

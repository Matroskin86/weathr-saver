#import <ScreenSaver/ScreenSaver.h>
#import "weathr.h"

@interface WeatherSaverView : ScreenSaverView
{
    NSInteger frameCount;
}
@end

@implementation WeatherSaverView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        frameCount = 0;
        NSLog(@"WeatherSaver: initializing...");
        
        weathr_init();
        
        NSLog(@"WeatherSaver: initialized successfully");
        [self setAnimationTimeInterval:0.1];
    }
    return self;
}

- (void)startAnimation
{
    [super startAnimation];
    NSLog(@"WeatherSaver: startAnimation");
}

- (void)stopAnimation
{
    [super stopAnimation];
    NSLog(@"WeatherSaver: stopAnimation");
}

- (void)drawRect:(NSRect)rect
{
    NSLog(@"WeatherSaver: drawRect called, frame %ld", (long)frameCount);
    
    [[NSColor blackColor] setFill];
    NSRectFill(rect);
    
    weathr_update_if_needed();
    
    char *frame = weathr_render_frame();
    NSString *text = @"Loading...";
    if (frame != NULL) {
        text = [NSString stringWithUTF8String:frame];
        weathr_free_string(frame);
    }
    
    NSFont *font = [NSFont fontWithName:@"Menlo" size:10];
    if (!font) {
        font = [NSFont monospacedSystemFontOfSize:10 weight:NSFontWeightRegular];
    }
    
    NSDictionary *attrs = @{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: [NSColor whiteColor]
    };
    
    NSSize textSize = [text sizeWithAttributes:attrs];
    
    NSPoint textPoint;
    textPoint.x = 10;
    textPoint.y = rect.size.height - textSize.height - 10;
    
    [text drawAtPoint:textPoint withAttributes:attrs];
    
    frameCount++;
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

@end

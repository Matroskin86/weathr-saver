#import <ScreenSaver/ScreenSaver.h>
#import "weathr.h"

@interface WeatherSaverView : ScreenSaverView
@end

@implementation WeatherSaverView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        NSLog(@"WeatherSaver: STARTED");
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
    // ALWAYS show RED first to prove drawRect is called
    [[NSColor redColor] setFill];
    NSRectFill(rect);
    
    NSLog(@"WeatherSaver: drawRect called");
    
    // Draw text
    NSString *text = @"RED = NO RUST - This should work!";
    NSFont *font = [NSFont systemFontOfSize:14];
    NSDictionary *attrs = @{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: [NSColor whiteColor]
    };
    
    [text drawAtPoint:NSMakePoint(50, rect.size.height/2) withAttributes:attrs];
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

@end

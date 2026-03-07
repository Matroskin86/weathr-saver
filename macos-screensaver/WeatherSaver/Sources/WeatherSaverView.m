#import <ScreenSaver/ScreenSaver.h>

@interface WeatherSaverView : ScreenSaverView
@end

@implementation WeatherSaverView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        NSLog(@"WeatherSaver: INITIALIZED");
        [self setAnimationTimeInterval:0.5];
    }
    return self;
}

- (void)animateOneFrame
{
    NSLog(@"WeatherSaver: animateOneFrame");
    [self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect
{
    NSLog(@"WeatherSaver: drawRect");
    
    // RED background - very visible!
    [[NSColor redColor] setFill];
    NSRectFill(rect);
    
    // White text
    NSString *text = @"SCREENSAVER WORKS!";
    NSFont *font = [NSFont boldSystemFontOfSize:48];
    
    NSDictionary *attrs = @{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: [NSColor whiteColor]
    };
    
    NSSize textSize = [text sizeWithAttributes:attrs];
    NSPoint textPoint;
    textPoint.x = (rect.size.width - textSize.width) / 2;
    textPoint.y = (rect.size.height - textSize.height) / 2;
    
    [text drawAtPoint:textPoint withAttributes:attrs];
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

@end

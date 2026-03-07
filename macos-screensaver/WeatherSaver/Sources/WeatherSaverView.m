#import <ScreenSaver/ScreenSaver.h>

@interface WeatherSaverView : ScreenSaverView
{
    NSTimer *animationTimer;
    NSInteger frameCount;
}

@end

@implementation WeatherSaverView

- (instancetype)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self = [super initWithFrame:frame isPreview:isPreview];
    if (self) {
        frameCount = 0;
        NSLog(@"WeatherSaver: initialized with frame %@", NSStringFromRect(frame));
        [self setAnimationTimeInterval:1.0];
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
    
    // Black background
    [[NSColor blackColor] setFill];
    NSRectFill(rect);
    
    // White text
    NSFont *font = [NSFont fontWithName:@"Menlo" size:12];
    if (!font) {
        font = [NSFont monospacedSystemFontOfSize:12 weight:NSFontWeightRegular];
    }
    
    NSDictionary *attrs = @{
        NSFontAttributeName: font,
        NSForegroundColorAttributeName: [NSColor whiteColor]
    };
    
    NSString *text = [self createFrame];
    NSSize textSize = [text sizeWithAttributes:attrs];
    
    NSPoint textPoint;
    textPoint.x = (rect.size.width - textSize.width) / 2;
    textPoint.y = (rect.size.height - textSize.height) / 2;
    
    [text drawAtPoint:textPoint withAttributes:attrs];
    
    frameCount++;
}

- (NSString *)createFrame
{
    return [NSString stringWithFormat:@"\
========================================\n\
WEATHER SCREENSAVER\n\
Frame: %ld\n\
Size: %.0f x %.0f\n\
========================================\n\
     .   .   .\n\
  .    CLEAR    .\n\
     ~ ~ ~ ~\n\
Temperature: 22°C\n\
Wind: 12 km/h\n\
========================================",
        (long)frameCount,
        self.bounds.size.width,
        self.bounds.size.height
    ];
}

- (BOOL)hasConfigureSheet
{
    return NO;
}

@end

import ScreenSaver
import Foundation

class WeatherSaverView: ScreenSaverView {
    
    private var frameString: String = "Loading..."
    private var counter: Int = 0
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        animationTimeInterval = 1.0
        NSLog("WeatherSaver: initialized")
        frameString = createFrame()
    }
    
    private func createFrame() -> String {
        counter += 1
        return """
            ========================================
            WEATHER SCREENSAVER
            Frame: \(counter)
            Size: \(Int(bounds.width)) x \(Int(bounds.height))
            ========================================
            
                 .   .   .
            
              .    CLEAR    .
            
                 ~ ~ ~ ~
            
            Temperature: 22°C
            Wind: 12 km/h
            
            ========================================
            """
    }
    
    override func draw(_ rect: NSRect) {
        NSLog("WeatherSaver: draw() called")
        
        NSColor.black.setFill()
        bounds.fill()
        
        let font = NSFont(name: "Menlo", size: 12) ?? NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.white
        ]
        
        let string = NSAttributedString(string: frameString, attributes: attributes)
        
        let size = string.size()
        let x = (bounds.width - size.width) / 2
        let y = (bounds.height - size.height) / 2
        
        string.draw(at: NSPoint(x: x, y: y))
        
        NSLog("WeatherSaver: drew frame at (\(x), \(y)) size (\(size.width), \(size.height))")
    }
    
    override func animateOneFrame() {
        NSLog("WeatherSaver: animateOneFrame() called")
        frameString = createFrame()
        needsDisplay = true
    }
    
    override var hasConfigureSheet: Bool {
        return false
    }
}

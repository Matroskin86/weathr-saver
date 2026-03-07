import ScreenSaver
import Foundation

class WeatherSaverView: ScreenSaverView {
    
    private var frameString: String = ""
    private var frameCount: Int = 0
    
    override init?(frame: NSRect, isPreview: Bool) {
        super.init(frame: frame, isPreview: isPreview)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        animationTimeInterval = 1.0 / 10.0
        frameString = generateDemoFrame()
    }
    
    private func generateDemoFrame() -> String {
        let lines = [
            "                                    .",
            "      .   .   .        .    .        .   .",
            "   .         .    .         .    .",
            "        _   _   _   _   _   _   _   _   _",
            "   .   |   |   |   |   |   |   |   |   |   .",
            "      _|___|___|___|___|___|___|___|___|___",
            "     |   |   |   |   |   |   |   |   |   |",
            "   __|___|___|___|___|___|___|___|___|___|__",
            "  |                                      |",
            "  |  ☀  CLEAR SKY    22°C               |",
            "  |  Wind: 12 km/h                       |",
            "  |                                      |",
            "      ^       |        ^        |",
            "     ^^^      |       ^^^       |",
            "    _______  _|_     _______   _|_",
            "   |       ||   |   |       | |   |",
            "   |___   ||___|   |___   | |___|",
            "      |___||       |      |___|",
            "   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
            "   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~",
            "                                    ,   ,",
            "                                , ,,, , ,",
            "                              ,,,,,   ,,,,",
            "                            ,,,,,,,, ,,,,",
        ]
        return lines.joined(separator: "\n")
    }
    
    override func draw(_ rect: NSRect) {
        NSColor.black.setFill()
        rect.fill()
        
        let fontSize = calculateFontSize()
        guard let font = NSFont(name: "Menlo", size: fontSize) else { return }
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.white,
            .backgroundColor: NSColor.black
        ]
        
        let attributedString = NSAttributedString(string: frameString, attributes: attributes)
        
        let textSize = attributedString.size()
        let textRect = NSRect(
            x: (bounds.width - textSize.width) / 2,
            y: (bounds.height - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        attributedString.draw(in: textRect)
    }
    
    private func calculateFontSize() -> CGFloat {
        let baseWidth: CGFloat = 80
        let baseHeight: CGFloat = 24
        let scaleX = bounds.width / (baseWidth * 8)
        let scaleY = bounds.height / (baseHeight * 14)
        let scale = min(scaleX, scaleY)
        return max(8, min(24, scale * 12))
    }
    
    override func animateOneFrame() {
        setNeedsDisplay(bounds)
    }
    
    override var hasConfigureSheet: Bool {
        return false
    }
}

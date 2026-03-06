import ScreenSaver
import Foundation

class WeatherSaverView: ScreenSaverView {
    
    private var frameString: String = ""
    private var lastUpdateTime: Date = Date()
    private var useMetric: Bool = true
    private var refreshInterval: TimeInterval = 600
    private var configuredCity: String = "Berlin"
    private var configuredLat: Double = 52.52
    private var configuredLon: Double = 13.41
    
    private let defaultsKey = "WeatherSaverDefaults"
    private let cityKey = "city"
    private let latKey = "latitude"
    private let lonKey = "longitude"
    private let metricKey = "useMetric"
    private let refreshKey = "refreshInterval"
    
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
        loadDefaults()
        initializeWeather()
    }
    
    private func loadDefaults() {
        guard let defaults = ScreenSaverDefaults(forModuleWithName: defaultsKey) else { return }
        
        defaults.register(defaults: [
            cityKey: "Berlin",
            latKey: 52.52,
            lonKey: 13.41,
            metricKey: true,
            refreshKey: 600.0
        ])
        
        configuredCity = defaults.string(forKey: cityKey) ?? "Berlin"
        configuredLat = defaults.double(forKey: latKey)
        configuredLon = defaults.double(forKey: lonKey)
        useMetric = defaults.bool(forKey: metricKey)
        refreshInterval = defaults.double(forKey: refreshKey)
        
        if configuredLat == 0 {
            configuredLat = 52.52
            configuredLon = 13.41
        }
    }
    
    private func initializeWeather() {
        let cityCString = configuredCity.withCString { str -> UnsafePointer<CChar> in
            return str
        }
        
        weathr_init_with_location(configuredLat, configuredLon, useMetric, cityCString)
    }
    
    override func startAnimation() {
        super.startAnimation()
        lastUpdateTime = Date()
    }
    
    override func stopAnimation() {
        super.stopAnimation()
    }
    
    override func draw(_ rect: NSRect) {
        NSColor.black.setFill()
        rect.fill()
        
        guard let font = NSFont(name: "Menlo", size: calculateFontSize()) else { return }
        
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
        let now = Date()
        
        if now.timeIntervalSince(lastUpdateTime) >= refreshInterval {
            weathr_update()
            lastUpdateTime = now
        }
        
        weathr_update_if_needed()
        
        if let cString = weathr_render_frame() {
            frameString = String(cString: cString)
            weathr_free_string(cString)
        }
        
        setNeedsDisplay(bounds)
    }
    
    override var hasConfigureSheet: Bool {
        return true
    }
    
    override var configureSheet: NSWindow? {
        let controller = ConfigureSheetController(
            city: configuredCity,
            lat: configuredLat,
            lon: configuredLon,
            useMetric: useMetric,
            refreshInterval: refreshInterval
        ) { [weak self] city, lat, lon, metric, refresh in
            self?.configuredCity = city
            self?.configuredLat = lat
            self?.configuredLon = lon
            self?.useMetric = metric
            self?.refreshInterval = refresh
            
            guard let defaults = ScreenSaverDefaults(forModuleWithName: self?.defaultsKey ?? "") else { return }
            
            defaults.set(city, forKey: self?.cityKey ?? "")
            defaults.set(lat, forKey: self?.latKey ?? "")
            defaults.set(lon, forKey: self?.lonKey ?? "")
            defaults.set(metric, forKey: self?.metricKey ?? "")
            defaults.set(refresh, forKey: self?.refreshKey ?? "")
            defaults.synchronize()
            
            self?.initializeWeather()
        }
        
        return controller.window
    }
}

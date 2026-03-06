import AppKit
import ScreenSaver

class ConfigureSheetController: NSObject {
    
    let window: NSWindow
    private var onSave: (String, Double, Double, Bool, TimeInterval) -> Void
    
    private let cityTextField = NSTextField()
    private let latTextField = NSTextField()
    private let lonTextField = NSTextField()
    private let metricCheckbox = NSButton(checkboxWithTitle: "Use Metric (°C)", target: nil, action: nil)
    private let refreshPopup = NSPopUpButton()
    
    init(city: String, lat: Double, lon: Double, useMetric: Bool, refreshInterval: TimeInterval, onSave: @escaping (String, Double, Double, Bool, TimeInterval) -> Void) {
        self.onSave = onSave
        
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 280),
            styleMask: [.titled],
            backing: .buffered,
            defer: true
        )
        window.title = "Weather Saver Settings"
        
        super.init()
        
        setupUI(city: city, lat: lat, lon: lon, useMetric: useMetric, refreshInterval: refreshInterval)
    }
    
    private func setupUI(city: String, lat: Double, lon: Double, useMetric: Bool, refreshInterval: TimeInterval) {
        guard let contentView = window.contentView else { return }
        
        let padding: CGFloat = 20
        var yOffset: CGFloat = 240
        
        let titleLabel = NSTextField(labelWithString: "Weather Screen Saver Configuration")
        titleLabel.font = NSFont.boldSystemFont(ofSize: 14)
        titleLabel.frame = NSRect(x: padding, y: yOffset, width: 360, height: 20)
        contentView.addSubview(titleLabel)
        
        yOffset -= 40
        
        let cityLabel = NSTextField(labelWithString: "City:")
        cityLabel.frame = NSRect(x: padding, y: yOffset, width: 80, height: 20)
        contentView.addSubview(cityLabel)
        
        cityTextField.frame = NSRect(x: 110, y: yOffset - 2, width: 270, height: 24)
        cityTextField.stringValue = city
        cityTextField.placeholderString = "Enter city name"
        contentView.addSubview(cityTextField)
        
        yOffset -= 40
        
        let latLabel = NSTextField(labelWithString: "Latitude:")
        latLabel.frame = NSRect(x: padding, y: yOffset, width: 80, height: 20)
        contentView.addSubview(latLabel)
        
        latTextField.frame = NSRect(x: 110, y: yOffset - 2, width: 120, height: 24)
        latTextField.stringValue = String(format: "%.4f", lat)
        latTextField.placeholderString = "e.g., 52.52"
        contentView.addSubview(latTextField)
        
        let lonLabel = NSTextField(labelWithString: "Longitude:")
        lonLabel.frame = NSRect(x: 240, y: yOffset, width: 80, height: 20)
        contentView.addSubview(lonLabel)
        
        lonTextField.frame = NSRect(x: 320, y: yOffset - 2, width: 60, height: 24)
        lonTextField.stringValue = String(format: "%.4f", lon)
        lonTextField.placeholderString = "13.41"
        contentView.addSubview(lonTextField)
        
        yOffset -= 40
        
        metricCheckbox.frame = NSRect(x: padding, y: yOffset, width: 200, height: 20)
        metricCheckbox.state = useMetric ? .on : .off
        contentView.addSubview(metricCheckbox)
        
        yOffset -= 40
        
        let refreshLabel = NSTextField(labelWithString: "Update Interval:")
        refreshLabel.frame = NSRect(x: padding, y: yOffset, width: 100, height: 20)
        contentView.addSubview(refreshLabel)
        
        refreshPopup.frame = NSRect(x: 120, y: yOffset - 2, width: 150, height: 24)
        refreshPopup.addItems(withTitles: [
            "5 minutes",
            "10 minutes",
            "15 minutes",
            "30 minutes",
            "1 hour"
        ])
        
        let intervalMap: [TimeInterval] = [300, 600, 900, 1800, 3600]
        if let index = intervalMap.firstIndex(of: refreshInterval) {
            refreshPopup.selectItem(at: index)
        } else {
            refreshPopup.selectItem(at: 1)
        }
        contentView.addSubview(refreshPopup)
        
        yOffset -= 50
        
        let cancelButton = NSButton(title: "Cancel", target: self, action: #selector(cancelClicked))
        cancelButton.frame = NSRect(x: padding, y: yOffset, width: 80, height: 30)
        cancelButton.bezelStyle = .rounded
        contentView.addSubview(cancelButton)
        
        let saveButton = NSButton(title: "Save", target: self, action: #selector(saveClicked))
        saveButton.frame = NSRect(x: 300, y: yOffset, width: 80, height: 30)
        saveButton.bezelStyle = .rounded
        saveButton.keyEquivalent = "\r"
        contentView.addSubview(saveButton)
        
        let noteLabel = NSTextField(wrappingLabelWithString: "Note: Location can be set manually. For best results, enter coordinates for your city.")
        noteLabel.frame = NSRect(x: padding, y: 10, width: 360, height: 30)
        noteLabel.font = NSFont.systemFont(ofSize: 10)
        noteLabel.textColor = NSColor.secondaryLabelColor
        contentView.addSubview(noteLabel)
    }
    
    @objc private func cancelClicked() {
        window.sheetParent?.endSheet(window, returnCode: .cancel)
    }
    
    @objc private func saveClicked() {
        let city = cityTextField.stringValue.isEmpty ? "Berlin" : cityTextField.stringValue
        let lat = Double(latTextField.stringValue) ?? 52.52
        let lon = Double(lonTextField.stringValue) ?? 13.41
        let metric = metricCheckbox.state == .on
        
        let intervals: [TimeInterval] = [300, 600, 900, 1800, 3600]
        let refreshInterval = intervals[refreshPopup.indexOfSelectedItem]
        
        onSave(city, lat, lon, metric, refreshInterval)
        
        window.sheetParent?.endSheet(window, returnCode: .OK)
    }
}

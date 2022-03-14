import UIKit

// https://applelocalization.com
enum LocalizedString {
    private static let uikitBundle = Bundle(for: UIView.self)
    static func uikitLocalize(_ key: String) -> String {
        uikitBundle.localizedString(forKey: key, value: nil, table: nil)
    }
    
    static var color: String { uikitLocalize("Color") }
    static var grid: String { uikitLocalize("Grid") }
    static var sliders: String { uikitLocalize("Sliders") }
    static var red: String { uikitLocalize("Red") }
    static var blue: String { uikitLocalize("Blue") }
    static var green: String { uikitLocalize("Green") }
}

import UIKit

// https://applelocalization.com
enum LocalizedString {
    private static let uikitBundle = Bundle(for: UIView.self)
    static func uikitLocalize(_ key: String) -> String {
        uikitBundle.localizedString(forKey: key, value: nil, table: nil)
    }
    static func localize(_ key: String) -> String {
        Bundle.module.localizedString(forKey: key, value: nil, table: nil)
    }

    static var color: String { uikitLocalize("Color") }
    static var grid: String { uikitLocalize("Grid") }
    static var sliders: String { uikitLocalize("Sliders") }
    static var red: String { uikitLocalize("Red") }
    static var blue: String { uikitLocalize("Blue") }
    static var green: String { uikitLocalize("Green") }
    static var hue: String { localize("Hue") }
    static var brightness: String { localize("Brightness") }
    static var saturation: String { localize("Saturation") }
    static var classic: String { localize("Classic") }
    static var rgb: String { uikitLocalize("RGB") }
    static var hsb: String { uikitLocalize("HSB") }
    static var opacity: String { uikitLocalize("Opacity") }
    static var delete: String { localize("Delete") }
}

import Foundation
import UIKit

class ColorFormatter: Formatter {

    func color(from string: String) -> HSVA? {
        let hexString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)

        if hexString.hasPrefix("#") {
            scanner.currentIndex = scanner.string.index(after: scanner.string.startIndex)
        }

        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)

        let r: Double = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let g: Double = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let b: Double = Double(rgbValue & 0x0000FF) / 255.0
        let a: Double = 1

        return HSVA(hsv: RGB(r: r, g: g, b: b).hsv, a: a)
    }

    func string(from color: HSVA) -> String {
        let r: CGFloat = color.hsv.rgb.r
        let g: CGFloat = color.hsv.rgb.g
        let b: CGFloat = color.hsv.rgb.b

        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0

        return String(format: "%06x", rgb)
    }
}

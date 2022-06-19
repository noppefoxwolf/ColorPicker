import Foundation
import UIKit

class ColorFormatter: Formatter {
    
    func color(from string: String) -> CGColor? {
        let hexString = string.trimmingCharacters(in: .whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        
        if hexString.hasPrefix("#") {
            scanner.currentIndex = scanner.string.index(after: scanner.string.startIndex)
        }
        
        var rgbValue:UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        
        return CGColor(
            red: Double((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: Double((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgbValue & 0x0000FF) / 255.0,
            alpha: 1.0
        )
    }
    
    func string(from color: CGColor) -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r * 255) << 16 | (Int)(g * 255) << 8 | (Int)(b * 255) << 0
        
        return String(format: "%06x", rgb)
    }
}

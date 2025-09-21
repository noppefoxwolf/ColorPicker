import UIKit

struct RGB {
    var r, g, b: Double
}

extension RGB {
    func makeColor() -> UIColor {
        UIColor(red: r, green: g, blue: b, alpha: 1)
    }

    var hsv: HSV {
        HSVA(makeColor()).hsv
    }
}

struct RGBA {
    var rgb: RGB
    var a: Double
}

extension RGBA {
    init(_ color: UIColor) {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        self.rgb = RGB(r: r, g: g, b: b)
        self.a = a
    }

    func makeColor() -> UIColor {
        rgb.makeColor().withAlphaComponent(a)
    }
}

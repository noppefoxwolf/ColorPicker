import Darwin
import UIKit

public struct HSV: Equatable, Hashable {
    var h: Double // Angle in degrees [0,1] or -1 as Undefined
    var s: Double // Percent [0,1]
    var v: Double // Percent [0,1]
    
    static func rgb(h: Double, s: Double, v: Double) -> RGB {
        if s == 0 { return RGB(r: v, g: v, b: v) } // Achromatic grey
        
        let angle = (h >= 1.0 ? 0 : h)
        let sector = angle * 360 / 60 // Sector
        let i = floor(sector)
        let f = sector - i // Factorial part of h
        
        let p = v * (1 - s)
        let q = v * (1 - (s * f))
        let t = v * (1 - (s * (1 - f)))
        
        switch(i) {
        case 0:
            return RGB(r: v, g: t, b: p)
        case 1:
            return RGB(r: q, g: v, b: p)
        case 2:
            return RGB(r: p, g: v, b: t)
        case 3:
            return RGB(r: p, g: q, b: v)
        case 4:
            return RGB(r: t, g: p, b: v)
        default:
            return RGB(r: v, g: p, b: q)
        }
    }
    
    static func rgb(hsv: HSV) -> RGB {
        return rgb(h: hsv.h, s: hsv.s, v: hsv.v)
    }
    
    var rgb: RGB {
        HSV.rgb(hsv: self)
    }
}

public struct HSVA: Equatable, Hashable {
    var hsv: HSV
    var a: Double
}

extension HSVA {
    public init(_ color: UIColor) {
        var h: CGFloat = 0
        var s: CGFloat = 0
        var v: CGFloat = 0
        var a: CGFloat = 0
        color.getHue(&h, saturation: &s, brightness: &v, alpha: &a)
        self.hsv = HSV(h: h, s: s, v: v)
        self.a = a
    }
    
    func makeColor() -> UIColor {
        UIColor(hue: hsv.h, saturation: hsv.s, brightness: hsv.v, alpha: a)
    }
}

extension HSVA {
    @available(*, deprecated)
    static var white: HSVA = .init(hsv: HSV(h: 1, s: 1, v: 1), a: 1)
}

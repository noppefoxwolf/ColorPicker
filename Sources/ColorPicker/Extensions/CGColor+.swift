import CoreGraphics

extension CGColor {
    static func make(
        hue: Double,
        saturation: Double,
        brightness: Double,
        alpha: Double
    ) -> CGColor {
        let rgb = HSV.rgb(h: hue, s: saturation, v: brightness)
        return CGColor(red: rgb.r, green: rgb.g, blue: rgb.b, alpha: alpha)
    }
    
    func getRed(
        _ red: UnsafeMutablePointer<CGFloat>?,
        green: UnsafeMutablePointer<CGFloat>?,
        blue: UnsafeMutablePointer<CGFloat>?,
        alpha: UnsafeMutablePointer<CGFloat>?
    ) {
        let rgb = self.rgb
        red?.pointee = rgb.r
        green?.pointee = rgb.g
        blue?.pointee = rgb.b
        alpha?.pointee = 1
    }
    
    func getHue(
        _ hue: UnsafeMutablePointer<CGFloat>?,
        saturation: UnsafeMutablePointer<CGFloat>?,
        brightness: UnsafeMutablePointer<CGFloat>?,
        alpha: UnsafeMutablePointer<CGFloat>?
    ) {
        let hsb = self.hsb
        hue?.pointee = hsb.h
        saturation?.pointee = hsb.s
        brightness?.pointee = hsb.v
        alpha?.pointee = 1
    }
    
    var rgb: RGB {
        RGB(
            r: components![0],
            g: components![1],
            b: components![2]
        )
    }
    
    var hsb: HSV {
        rgb.hsv
    }
}

extension CGColor {
    static let white: CGColor = CGColor(gray: 0, alpha: 1)
}

// https://www.cs.rit.edu/~ncs/color/t_convert.html
struct RGB {
    // Percent
    let r: Double // [0,1]
    let g: Double // [0,1]
    let b: Double // [0,1]
    
    static func hsv(r: Double, g: Double, b: Double) -> HSV {
        let min = r < g ? (r < b ? r : b) : (g < b ? g : b)
        let max = r > g ? (r > b ? r : b) : (g > b ? g : b)
        
        let v = max
        let delta = max - min
        
        guard delta > 0.00001 else { return HSV(h: 0, s: 0, v: max) }
        guard max > 0 else { return HSV(h: -1, s: 0, v: v) } // Undefined, achromatic grey
        let s = delta / max
        
        let hue: (Double, Double) -> Double = { max, delta -> Double in
            if r == max { return (g-b)/delta } // between yellow & magenta
            else if g == max { return 2 + (b-r)/delta } // between cyan & yellow
            else { return 4 + (r-g)/delta } // between magenta & cyan
        }
        
        let h = hue(max, delta) * 60 // In degrees
        
        return HSV(h: (h < 0 ? h+360 : h) / 360, s: s, v: v)
    }
    
    static func hsv(rgb: RGB) -> HSV {
        return hsv(r: rgb.r, g: rgb.g, b: rgb.b)
    }
    
    var hsv: HSV {
        return RGB.hsv(rgb: self)
    }
}

struct RGBA {
    let a: Double
    let rgb: RGB
    
    init(r: Double, g: Double, b: Double, a: Double) {
        self.a = a
        self.rgb = RGB(r: r, g: g, b: b)
    }
}

struct HSV {
    let h: Double // Angle in degrees [0,1] or -1 as Undefined
    let s: Double // Percent [0,1]
    let v: Double // Percent [0,1]
    
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
        return HSV.rgb(hsv: self)
    }
}

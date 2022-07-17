// https://www.cs.rit.edu/~ncs/color/t_convert.html
struct RGB {
    // Percent
    var r: Double // [0,1]
    var g: Double // [0,1]
    var b: Double // [0,1]
    
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
    var rgb: RGB
    var a: Double
    
    init(r: Double, g: Double, b: Double, a: Double) {
        self.a = a
        self.rgb = RGB(r: r, g: g, b: b)
    }
}


import CoreGraphics

extension CGColor {
    static func make(
        hsv: HSV,
        alpha: Double
    ) -> CGColor {
        let rgb = hsv.rgb
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
    static let white: CGColor = CGColor(red: 0, green: 0, blue: 0, alpha: 1)
}

extension CGColor {
    func withAlphaComponent(_ alpha: Double) -> CGColor {
        let rgb = rgb
        return CGColor(
            red: rgb.r,
            green: rgb.g,
            blue: rgb.b,
            alpha: alpha
        )
    }
}

import UIKit

class ClassicColorView: UIView {    
    @Invalidating(.display)
    var hue: Double = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        self.snp.makeConstraints { make in
            make.height.equalTo(self.snp.width).multipliedBy(3.0 / 4.0)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func color(at location: CGPoint) -> UIColor {
        let saturation = location.x / bounds.width
        let brightness = 1.0 - (location.y / bounds.height)
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: 1)
    }
    
    func location(by color: UIColor) -> CGPoint? {
        let (_, saturation, brightness, _) = color.hsba
        return CGPoint(x: saturation * bounds.width, y: (1.0 - brightness) * bounds.height)
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        let maskPath = UIBezierPath(roundedRect: rect, cornerRadius: 8).cgPath
        context.addPath(maskPath)
        context.clip()
        
        let grayGradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [UIColor.white.cgColor, UIColor.black.cgColor] as CFArray,
            locations: [0, 1]
        )!
        context.drawLinearGradient(
            grayGradient,
            start: CGPoint(x: rect.midX, y: rect.minY),
            end: CGPoint(x: rect.midX, y: rect.maxY),
            options: .drawsAfterEndLocation
        )
        let color = UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1)
        let colorGradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: [UIColor.clear.cgColor, color.cgColor] as CFArray,
            locations: [0, 1]
        )!
        context.setBlendMode(.multiply)
        context.drawLinearGradient(
            colorGradient,
            start: CGPoint(x: rect.minX, y: rect.midY),
            end: CGPoint(x: rect.maxX, y: rect.midY),
            options: .drawsAfterEndLocation
        )
    }
}


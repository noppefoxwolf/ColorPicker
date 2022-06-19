import UIKit

class ReticleView: UIView {
    // shadow and internal
    let internalReticleView: InternalReticleView = .init(frame: .null)
    var color: CGColor {
        get { internalReticleView.color }
        set { internalReticleView.color = newValue }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(internalReticleView)
        internalReticleView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        internalReticleView.layer.cornerRadius = bounds.width / 2
        internalReticleView.layer.masksToBounds = true
        
        let shadowPath = UIBezierPath(ovalIn: bounds)
        layer.shadowPath = shadowPath.cgPath
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 30
    }
    
    func render(_ renderAction: (_ context: CGContext) -> Void) {
        let width: Int = 9
        let context = CGContext(
            data: nil,
            width: width,
            height: width,
            bitsPerComponent: 8,
            bytesPerRow: 4 * width, //0にするとautoになるが、16の倍数になってしまう
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        )!
        context.setAllowsAntialiasing(false)
        context.interpolationQuality = .none
        renderAction(context)
        
        struct Pixel {
            let r, g, b, a: UInt8
        }
        let centerColor = context.data!.load(
            fromByteOffset: MemoryLayout<Pixel>.size * 40,
            as: Pixel.self
        )
        self.color = CGColor(
            red: Double(centerColor.r) / 255,
            green: Double(centerColor.g) / 255,
            blue: Double(centerColor.b) / 255,
            alpha: Double(centerColor.a) / 255
        )
        internalReticleView.imageView.image = UIImage(cgImage: context.makeImage()!, scale: 1, orientation: .downMirrored)
    }
}

class InternalReticleView: UIView {
    // image
    // grid
    // outline
    let imageView: UIImageView = .init(frame: .null)
    let gridView: ReticleGridView = .init(frame: .null)
    let outlineView: ReticleOutlineView = .init(frame: .null)
    
    var color: CGColor {
        get { outlineView.color }
        set {
            outlineView.color = newValue
            var brightness: CGFloat = 0
            newValue.getHue(nil, saturation: nil, brightness: &brightness, alpha: nil)
            outlineView.gridColor = brightness > 0.9 ? .gray : .white
            gridView.strokeColor = brightness > 0.9 ? .gray : .white
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.backgroundColor = .clear
        imageView.layer.magnificationFilter = .nearest
            
        addSubview(imageView)
        addSubview(gridView)
        addSubview(outlineView)
        imageView.snp.makeConstraints({ $0.edges.equalToSuperview().inset(15) })
        gridView.snp.makeConstraints({ $0.edges.equalToSuperview().inset(15) })
        outlineView.snp.makeConstraints({ $0.edges.equalToSuperview() })
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

class ReticleOutlineView: UIView {
    @Invalidating(.display)
    var color: CGColor = .white
    
    @Invalidating(.display)
    var gridColor: UIColor = .gray
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        drawInnerLine(rect: rect, context: context, color: gridColor.cgColor)
        drawOuterLine(rect: rect, context: context)
    }
    
    private func drawInnerLine(rect: CGRect, context: CGContext, color: CGColor) {
        let width: Double = 15
        context.setLineWidth(width)
        context.setStrokeColor(color)
        
        let newRect = CGRect(
            x: width / 2,
            y: width / 2,
            width: rect.width - width,
            height: rect.height - width
        )
        context.strokeEllipse(in: newRect)
    }
    
    private func drawOuterLine(rect: CGRect, context: CGContext) {
        let width: Double = 10
        context.setLineWidth(width)
        context.setStrokeColor(color)
        
        let newRect = CGRect(
            x: width / 2,
            y: width / 2,
            width: rect.width - width,
            height: rect.height - width
        )
        context.strokeEllipse(in: newRect)
    }
}

class ReticleGridView: UIView {
    @Invalidating(.display)
    var strokeColor: UIColor = .gray
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func draw(_ rect: CGRect) {
        let gridColor = strokeColor.cgColor
        
        let context = UIGraphicsGetCurrentContext()!
        let width: Int = 14
        let gridRect = CGRect(x: 0, y: 0, width: width, height: width)
        context.draw(gridCellImage(color: gridColor), in: gridRect, byTiling: true)
        
        // center square
        let roundSize = 14
        let path = UIBezierPath(
            roundedRect: CGRect(x: 56, y: 56, width: roundSize, height: roundSize),
            cornerRadius: 0
        ).cgPath
        context.setStrokeColor(gridColor)
        context.setLineWidth(3)
        context.addPath(path)
        context.strokePath()
    }
    
    func gridCellImage(color: CGColor) -> CGImage {
        let width: Int = 14
        let context = CGContext(
            data: nil,
            width: width,
            height: width,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue
        )!
        context.setAllowsAntialiasing(false)
        context.interpolationQuality = .none
        context.setLineWidth(1)
        context.setStrokeColor(color)
        context.move(to: CGPoint(x: width, y: 0))
        context.addLine(to: .zero)
        context.addLine(to: CGPoint(x: 0, y: width))
        context.strokePath()
        return context.makeImage()!
    }
}

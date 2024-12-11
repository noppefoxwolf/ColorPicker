import UIKit

open class ColorSlider: UIControl {
    
    @Invalidating(.constraints)
    private var _color: HSVA = .noop {
        didSet {
            thumbView.color = color
            trackView.grdient = configuration.gradientInvalidationHandler(color)
            value = configuration.colorToValue(color)
        }
    }
    
    var color: HSVA  {
        get { _color }
        set {
            guard _color != newValue else { return }
            _color = newValue
        }
    }
    
    @Invalidating(.constraints)
    private var _value: Double = 0 {
        didSet {
            color = configuration.valueToColor(_value, color)
        }
    }
    
    var value: Double {
        get { _value }
        set {
            // clamp value
            let newValue = min(max(newValue, 0), 1)
            guard _value != newValue else { return }
            _value = newValue
        }
    }
    
    let thumbView = ThumbView()
    let trackView = TrackView()
    let trackableLayoutGuide: UILayoutGuide = .init()
    let trackValueLayoutGuide: UILayoutGuide = .init()
    let panGestureRecognizer = UIPanGestureRecognizer()
    let tapGestureRecognizer = UITapGestureRecognizer()
    var configuration: ColorSliderConfiguration = .noop
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.snp.makeConstraints { make in
            make.height.equalTo(33)
        }
        
        addSubview(trackView)
        trackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        trackView.addLayoutGuide(trackableLayoutGuide)
        trackableLayoutGuide.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(34 / 2)
            make.verticalEdges.equalToSuperview()
        }
        trackView.addLayoutGuide(trackValueLayoutGuide)
        trackValueLayoutGuide.snp.makeConstraints { make in
            make.verticalEdges.left.equalTo(trackableLayoutGuide)
            make.width.equalTo(trackableLayoutGuide).multipliedBy(0)
        }
        
        addSubview(thumbView)
        thumbView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalTo(trackValueLayoutGuide.snp.right)
            make.size.equalTo(snp.height)
        }
        
        // touchesを使うとスクロールが干渉するのでPanGestureを使う
        panGestureRecognizer.addTarget(self, action: #selector(onPan))
        addGestureRecognizer(panGestureRecognizer)
        tapGestureRecognizer.addTarget(self, action: #selector(onTap))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc func onPan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        self.value = location.x / bounds.width
        self.sendActions(for: [.valueChanged, .primaryActionTriggered])
    }
    
    @objc func onTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else { return }
        let location = gesture.location(in: gesture.view)
        self.value = location.x / bounds.width
        self.sendActions(for: [.valueChanged, .primaryActionTriggered])
    }
    
    public override func setNeedsUpdateConstraints() {
        super.setNeedsUpdateConstraints()

        trackValueLayoutGuide.snp.remakeConstraints { make in
            make.verticalEdges.left.equalTo(trackableLayoutGuide)
            make.width.equalTo(trackableLayoutGuide).multipliedBy(value)
        }
    }
}

final class TrackView: UIView {
    @Invalidating(.display)
    var grdient: CGGradient = CGGradient(
        colorsSpace: CGColorSpaceCreateDeviceRGB(),
        colors: [UIColor.red.cgColor, UIColor.blue.cgColor] as CFArray,
        locations: [0, 1]
    )!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = frame.height / 2
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        
        context.draw(
            checkerboardImage(),
            in: CGRect(x: 0, y: 0, width: 22, height: 22),
            byTiling: true
        )
        
        context.drawLinearGradient(
            grdient,
            start: CGPoint(x: rect.minX, y: rect.midY),
            end: CGPoint(x: rect.maxX, y: rect.midY),
            options: .drawsAfterEndLocation
        )
    }
    
    func checkerboardImage() -> CGImage {
        let length: Int = 22
        let context = CGContext(
            data: nil,
            width: length,
            height: length,
            bitsPerComponent: 8,
            bytesPerRow: 0,
            space: CGColorSpaceCreateDeviceGray(),
            bitmapInfo: CGImageAlphaInfo.none.rawValue
        )!
        context.setFillColor(CGColor(gray: 1, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: length, height: length))
        context.setFillColor(CGColor(gray: 0.5, alpha: 1))
        context.fill([
            CGRect(
                x: 0,
                y: 0,
                width: length / 2,
                height: length / 2
            ),
            CGRect(
                x: length / 2,
                y: length / 2,
                width: length / 2,
                height: length / 2
            ),
        ])
        return context.makeImage()!
    }
}

final class ThumbView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @Invalidating(.display)
    private var _color: HSVA = .noop
    
    var color: HSVA {
        get { _color }
        set {
            guard _color != newValue else { return }
            _color = newValue
        }
    }
    
    override func draw(_ rect: CGRect) {
        let padding: Double = 2.0
        
        let context = UIGraphicsGetCurrentContext()!
        
        do {
            let x = padding
            let y = padding
            let h = rect.height - (padding + padding) // top + bottom
            let w = h
            context.setShadow(
                offset: .zero,
                blur: padding,
                color: CGColor(gray: 1, alpha: 1)
            )
            context.setFillColor(UIColor.white.cgColor)
            context.addEllipse(in: CGRect(x: x, y: y, width: w, height: h))
            context.fillPath()
        }
        
        do {
            let padding2: Double = 3
            let x = padding + padding2
            let y = padding + padding2
            let h = rect.height - (padding + padding) - (padding2 + padding2) // top + bottom
            let w = h
            context.setFillColor(color.makeColor().cgColor)
            context.addEllipse(in: CGRect(x: x, y: y, width: w, height: h))
            context.fillPath()
        }
    }
}

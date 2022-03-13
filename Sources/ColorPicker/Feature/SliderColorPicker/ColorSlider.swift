import UIKit
import Combine

open class ColorSlider: UIControl {
    
    @Invalidating(.constraints)
    var color: UIColor = .white {
        didSet {
            thumbView.color = color
            trackView.grdient = configuration.gradientInvalidationHandler(color)
            value = configuration.colorToValue(color)
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
    var configuration: ColorSliderConfiguration = .noop
    var cancellables: Set<AnyCancellable> = []
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.snp.makeConstraints { make in
            make.height.equalTo(34)
        }
        
        addSubview(trackView)
        trackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        addSubview(thumbView)
        thumbView.snp.makeConstraints { make in
            make.centerX.equalTo(0)
            make.size.equalTo(snp.height)
        }
        
        // touchesを使うとスクロールが干渉するのでPanGestureを使う
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan(_:)))
        addGestureRecognizer(panGesture)
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    @objc func onPan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        self.value = location.x / bounds.width
        self.sendActions(for: [.valueChanged, .primaryActionTriggered])
    }
    
    open override func setNeedsUpdateConstraints() {
        super.setNeedsUpdateConstraints()
        // タブの半径
        let paddingX = bounds.height / 2
        // 稼働幅
        let movableWidth = bounds.width - (paddingX + paddingX) // left + right
        let thumbCenterX = movableWidth * value + paddingX
        
        thumbView.snp.updateConstraints({ make in
            make.centerX.equalTo(thumbCenterX)
        })
    }
}

class TrackView: UIView {
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
        context.drawLinearGradient(
            grdient,
            start: CGPoint(x: rect.minX, y: rect.midY),
            end: CGPoint(x: rect.maxX, y: rect.midY),
            options: .drawsAfterEndLocation
        )
    }
}

class ThumbView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    @Invalidating(.display)
    var color: UIColor = .white
    
    override func draw(_ rect: CGRect) {
        let padding: Double = 2.0
        
        let context = UIGraphicsGetCurrentContext()!
        
        do {
            let x = padding
            let y = padding
            let h = rect.height - (padding + padding) // top + bottom
            let w = h
            context.setShadow(offset: .zero, blur: padding, color: CGColor(gray: 0, alpha: 1))
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
            context.setFillColor(color.cgColor)
            context.addEllipse(in: CGRect(x: x, y: y, width: w, height: h))
            context.fillPath()
        }
    }
}

import UIKit

class ClassicColorPicker: UIControl, ColorPicker {
    let id: String = #function
    var title: String = LocalizedString.classic
    
    let colorView: ClassicColorView = .init(frame: .null)
    let hueSlider: ColorSliderWithInputView = .init(frame: .null)
    let markerView: ClassicColorMarkerView = .init(frame: .null)
    
    @Invalidating(.constraints)
    private var _color: UIColor = .white
    
    var color: UIColor {
        get { _color }
        set {
            _color = newValue
            markerView.color = newValue
            hueSlider.color = newValue
            colorView.hue = newValue.hsba.hue
        }
    }
    
    let panGestureRecognizer = UIPanGestureRecognizer()
    let tapGestureRecognizer = UITapGestureRecognizer()
    
    var continuously: Bool {
        [
            panGestureRecognizer.state,
            hueSlider.slider.panGestureRecognizer.state,
        ].contains(.changed)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        hueSlider.slider.configuration = .hue
        hueSlider.textField.configuration = .radius
        
        let vStack = UIStackView(arrangedSubviews: [colorView, hueSlider])
        vStack.axis = .vertical
        addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        colorView.addSubview(markerView)
        markerView.snp.makeConstraints { make in
            make.center.equalTo(CGPoint.zero)
        }
        
        hueSlider.addAction(UIAction { [unowned self] _ in
            let location = colorView.location(by: color)!
            // hueをセットしてから色を取り出す
            colorView.hue = hueSlider.slider.value
            color = colorView.color(at: location)
            sendActions(for: [.primaryActionTriggered, .valueChanged])
        }, for: .primaryActionTriggered)
        
        panGestureRecognizer.addTarget(self, action: #selector(onPan))
        colorView.addGestureRecognizer(panGestureRecognizer)
        tapGestureRecognizer.addTarget(self, action: #selector(onTap))
        colorView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func onPan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        color = colorView.color(at: location)
        sendActions(for: [.primaryActionTriggered, .valueChanged])
    }
    
    @objc func onTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else { return }
        let location = gesture.location(in: gesture.view)
        color = colorView.color(at: location)
        sendActions(for: [.primaryActionTriggered, .valueChanged])
    }
    
    override func setNeedsUpdateConstraints() {
        super.setNeedsUpdateConstraints()
        let location = colorView.location(by: color)!
        markerView.snp.updateConstraints { make in
            make.center.equalTo(location)
        }
    }
}

class ClassicColorMarkerView: UIView {
    
    @Invalidating(.display)
    private var _color: UIColor = .white
    
    var color: UIColor {
        get { _color }
        set {
            guard _color != newValue else { return }
            _color = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        self.snp.makeConstraints { make in
            make.size.equalTo(36)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        let padding: CGFloat = 2
        let x = padding
        let y = padding
        let h = rect.height - (padding + padding) // top + bottom
        let w = h
        context.setShadow(offset: .zero, blur: padding, color: CGColor(gray: 0, alpha: 0.5))
        context.setFillColor(color.cgColor)
        context.addEllipse(in: CGRect(x: x, y: y, width: w, height: h))
        context.fillPath()
    }
}

import UIKit

public class ClassicColorPicker: UIControl, ColorPicker {
    public let id: String = #function
    public var title: String = LocalizedString.classic
    
    let colorView: ClassicColorView = .init(frame: .null)
    let hueSlider: ColorSliderWithInputView = .init(frame: .null)
    let thumbView: ThumbView = .init(frame: .null)
    
    @Invalidating(.constraints)
    private var _color: HSVA = .white
    
    public var color: HSVA {
        get { _color }
        set {
            _color = newValue
            thumbView.color = newValue
            hueSlider.color = newValue
            colorView.hue = newValue.hsv.h
        }
    }
    
    let panGestureRecognizer = UIPanGestureRecognizer()
    let tapGestureRecognizer = UITapGestureRecognizer()
    
    public var continuously: Bool {
        [
            panGestureRecognizer.state,
            hueSlider.slider.panGestureRecognizer.state,
        ].contains(.changed)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        hueSlider.slider.configuration = .hue
        hueSlider.textField.configuration = .radius
        
        let vStack = UIStackView(arrangedSubviews: [colorView, hueSlider])
        vStack.axis = .vertical
        addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        colorView.addSubview(thumbView)
        thumbView.snp.makeConstraints { make in
            make.centerX.equalTo(colorView.snp.right).multipliedBy(1.0)
            make.centerY.equalTo(colorView.snp.bottom).multipliedBy(1.0)
            make.size.equalTo(36)
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
    
    @available(*, unavailable)
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
    
    public override func setNeedsUpdateConstraints() {
        super.setNeedsUpdateConstraints()
        let multiply = colorView.locationMultiply(by: color)
        let multiplyX = max(multiply.width, .leastNonzeroMagnitude)
        let multiplyY = max(multiply.height, .leastNonzeroMagnitude)
        thumbView.snp.remakeConstraints { make in
            make.centerX.equalTo(colorView.snp.right).multipliedBy(multiplyX)
            make.centerY.equalTo(colorView.snp.bottom).multipliedBy(multiplyY)
            make.size.equalTo(36)
        }
    }
}


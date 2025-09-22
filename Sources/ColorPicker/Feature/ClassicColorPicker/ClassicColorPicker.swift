import UIKit

public struct ClassicColorPicker: ColorPicker {
    public let id: String = #function
    public let title: String = LocalizedString.classic

    public init() {}

    public typealias ColorPickerControl = ClassicColorPickerControl

    public func makeUIControl(_ color: HSVA) -> ColorPickerControl {
        ClassicColorPickerControl(frame: .null)
    }

    public func updateUIControl(_ uiView: ColorPickerControl, color: HSVA) {
        uiView.color = color
    }
}

public final class ClassicColorPickerControl: UIControl, ColorPickerView {
    let colorView: ClassicColorView = .init(frame: .null)
    let hueSlider: ColorSliderWithInputView = .init(frame: .null)
    let thumbView: ThumbView = .init(frame: .null)

    private var thumbCenterXConstraint: NSLayoutConstraint? = nil
    private var thumbCenterYConstraint: NSLayoutConstraint? = nil

    @Invalidating(.constraints)
    private var _color: HSVA = .noop

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
        ]
        .contains(.changed)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        hueSlider.slider.configuration = .hue
        hueSlider.textField.configuration = .radius

        let vStack = UIStackView(arrangedSubviews: [colorView, hueSlider])
        vStack.axis = .vertical
        addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: topAnchor),
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            vStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
        colorView.addSubview(thumbView)
        thumbView.translatesAutoresizingMaskIntoConstraints = false
        // Initial constraints: centerX = right * 1.0, centerY = bottom * 1.0, size = 36
        let cX = NSLayoutConstraint(
            item: thumbView,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: colorView,
            attribute: .right,
            multiplier: 1.0,
            constant: 0
        )
        let cY = NSLayoutConstraint(
            item: thumbView,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: colorView,
            attribute: .bottom,
            multiplier: 1.0,
            constant: 0
        )
        let w = thumbView.widthAnchor.constraint(equalToConstant: 36)
        let h = thumbView.heightAnchor.constraint(equalToConstant: 36)
        NSLayoutConstraint.activate([cX, cY, w, h])
        thumbCenterXConstraint = cX
        thumbCenterYConstraint = cY

        hueSlider.addAction(
            UIAction { [unowned self] _ in
                let location = colorView.location(by: color)!
                // hueをセットしてから色を取り出す
                colorView.hue = hueSlider.slider.value
                color = colorView.color(at: location)
                sendActions(for: [.primaryActionTriggered, .valueChanged])
            },
            for: .primaryActionTriggered
        )

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
        // Update constraints with new multipliers
        if let oldCX = thumbCenterXConstraint { oldCX.isActive = false }
        if let oldCY = thumbCenterYConstraint { oldCY.isActive = false }
        let newCX = NSLayoutConstraint(
            item: thumbView,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: colorView,
            attribute: .right,
            multiplier: multiplyX,
            constant: 0
        )
        let newCY = NSLayoutConstraint(
            item: thumbView,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: colorView,
            attribute: .bottom,
            multiplier: multiplyY,
            constant: 0
        )
        NSLayoutConstraint.activate([newCX, newCY])
        thumbCenterXConstraint = newCX
        thumbCenterYConstraint = newCY
    }
}

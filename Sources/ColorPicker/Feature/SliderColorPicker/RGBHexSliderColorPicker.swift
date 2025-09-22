import UIKit

public struct RGBHexSliderColorPicker: ColorPicker {
    public let id: String = #function
    public let title: String = LocalizedString.rgb

    public init() {}

    public typealias ColorPickerView = RGBHexSliderColorPickerControl

    public func makeUIControl(_ color: HSVA) -> ColorPickerView {
        RGBHexSliderColorPickerControl(frame: .null)
    }

    public func updateUIControl(_ uiView: ColorPickerView, color: HSVA) {
        uiView.color = color
    }
}

public final class RGBHexSliderColorPickerControl: UIControl, ColorPickerView {
    let rgbSlidersView = RGBColorSliderColorPickerControl(frame: .null)
    let hexInputView = HexInputView(frame: .null)

    private var _color: HSVA = .noop

    public var color: HSVA {
        get { _color }
        set {
            _color = newValue
            rgbSlidersView.color = newValue
            hexInputView.color = newValue
        }
    }

    public var continuously: Bool {
        [
            rgbSlidersView.continuously
        ]
        .contains(true)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        let vStack = UIStackView(arrangedSubviews: [rgbSlidersView, hexInputView])
        vStack.axis = .vertical
        vStack.spacing = 32
        addSubview(vStack)
        vStack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            vStack.topAnchor.constraint(equalTo: topAnchor),
            vStack.leadingAnchor.constraint(equalTo: leadingAnchor),
            vStack.trailingAnchor.constraint(equalTo: trailingAnchor),
            vStack.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        rgbSlidersView.addAction(
            UIAction { [unowned self] _ in
                self.color = self.rgbSlidersView.color
                self.sendActions(for: [.valueChanged, .primaryActionTriggered])
            },
            for: .primaryActionTriggered
        )

        hexInputView.addAction(
            UIAction { [unowned self] _ in
                self.color = self.hexInputView.color
                self.sendActions(for: [.valueChanged, .primaryActionTriggered])
            },
            for: .primaryActionTriggered
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

import UIKit

public struct RGBHSBHextSliderColorPicker: ColorPicker {
    public let id: String = #function
    public let title: String = LocalizedString.sliders

    public init() {}

    public typealias ColorPickerControl = RGBHSBHextSliderColorPickerControl

    public func makeUIControl(_ color: HSVA) -> ColorPickerControl {
        RGBHSBHextSliderColorPickerControl(frame: .null)
    }

    public func updateUIControl(_ uiView: ColorPickerControl, color: HSVA) {
        uiView.color = color
    }
}

/// RGBHSBHextSliderColorPicker
public final class RGBHSBHextSliderColorPickerControl: UIControl, ColorPickerView {
    let rgbSlidersView = RGBColorSliderColorPickerControl(frame: .null)
    let hsbSlidersView = HSBColorSliderColorPickerControl(frame: .null)
    let hexInputView = HexInputView(frame: .null)

    private var _color: HSVA = .noop

    public var color: HSVA {
        get { _color }
        set {
            _color = newValue
            rgbSlidersView.color = newValue
            hsbSlidersView.color = newValue
            hexInputView.color = newValue
        }
    }

    public var continuously: Bool {
        [
            rgbSlidersView.continuously,
            hsbSlidersView.continuously,
        ]
        .contains(true)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)

        let vStack = UIStackView(arrangedSubviews: [hsbSlidersView, rgbSlidersView, hexInputView])
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

        hsbSlidersView.addAction(
            UIAction { [unowned self] _ in
                self.color = self.hsbSlidersView.color
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

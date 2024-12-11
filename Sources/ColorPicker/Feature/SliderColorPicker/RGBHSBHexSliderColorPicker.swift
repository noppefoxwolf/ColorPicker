import UIKit

/// RGBHSBHextSliderColorPicker
public final class RGBHSBHextSliderColorPicker: UIControl, ColorPicker {
    public let id: String = #function
    public var title: String = LocalizedString.sliders
    
    let rgbSlidersView = RGBColorSliderColorPicker(frame: .null)
    let hsbSlidersView = HSBColorSliderColorPicker(frame: .null)
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
            hsbSlidersView.continuously
        ].contains(true)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        let vStack = UIStackView(arrangedSubviews: [hsbSlidersView, rgbSlidersView, hexInputView])
        vStack.axis = .vertical
        vStack.spacing = 32
        addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        rgbSlidersView.addAction(UIAction { [unowned self] _ in
            self.color = self.rgbSlidersView.color
            self.sendActions(for: [.valueChanged, .primaryActionTriggered])
        }, for: .primaryActionTriggered)
        
        hsbSlidersView.addAction(UIAction { [unowned self] _ in
            self.color = self.hsbSlidersView.color
            self.sendActions(for: [.valueChanged, .primaryActionTriggered])
        }, for: .primaryActionTriggered)
        
        hexInputView.addAction(UIAction { [unowned self] _ in
            self.color = self.hexInputView.color
            self.sendActions(for: [.valueChanged, .primaryActionTriggered])
        }, for: .primaryActionTriggered)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

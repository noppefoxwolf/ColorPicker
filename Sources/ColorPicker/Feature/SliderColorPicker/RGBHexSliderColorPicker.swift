import UIKit

public class RGBHexSliderColorPicker: UIControl, ColorPicker {
    public let id: String = #function
    public let title: String = LocalizedString.rgb
    
    let rgbSlidersView = RGBColorSliderColorPicker(frame: .null)
    let hexInputView = HexInputView(frame: .null)
    
    private var _color: CGColor = .white
    
    public var color: CGColor {
        get { _color }
        set {
            _color = newValue
            rgbSlidersView.color = newValue
            hexInputView.color = newValue
        }
    }
    
    public var continuously: Bool {
        [
            rgbSlidersView.continuously,
        ].contains(true)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        let vStack = UIStackView(arrangedSubviews: [rgbSlidersView, hexInputView])
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

import UIKit

class RGBHexSliderColorPicker: UIControl, ColorPicker {
    var title: String = LocalizedString.rgb
    
    let rgbSlidersView = RGBColorSlidersView(frame: .null)
    let hexInputView = HexInputView(frame: .null)
    
    private var _color: UIColor = .white
    
    var color: UIColor {
        get { _color }
        set {
            _color = newValue
            rgbSlidersView.color = newValue
            hexInputView.color = newValue
        }
    }
    
    var continuously: Bool {
        [
            rgbSlidersView.continuously,
        ].contains(true)
    }
    
    override init(frame: CGRect) {
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
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

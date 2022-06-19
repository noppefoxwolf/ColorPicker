import UIKit

class HSBHexSliderColorPicker: UIControl, ColorPicker {
    let id: String = #function
    var title: String = LocalizedString.hsb
    
    let hsbSlidersView = HSBColorSlidersView(frame: .null)
    let hexInputView = HexInputView(frame: .null)
    
    private var _color: UIColor = .white
    
    var color: UIColor {
        get { _color }
        set {
            _color = newValue
            hsbSlidersView.color = newValue
            hexInputView.color = newValue
        }
    }
    
    var continuously: Bool {
        [
            hsbSlidersView.continuously
        ].contains(true)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        let vStack = UIStackView(
            arrangedSubviews: [hsbSlidersView, hexInputView]
        )
        vStack.axis = .vertical
        vStack.spacing = 32
        addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        hsbSlidersView.addAction(UIAction { [unowned self] _ in
            self.color = self.hsbSlidersView.color
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

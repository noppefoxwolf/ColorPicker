import UIKit

final class SwatchAndPreviewView: UIControl {
    
    let swatchView = SwatchView(frame: .null)
    let colorPreviewView = ColorPreviewView(frame: .null)
    
    private var _color: HSVA = .noop
    
    var color: HSVA {
        get { _color }
        set {
            _color = newValue
            colorPreviewView.color = newValue
            swatchView.selectedColor = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let hStack = UIStackView(arrangedSubviews: [colorPreviewView, swatchView])
        hStack.spacing = 20
        hStack.axis = .horizontal
        hStack.alignment = .top
        addSubview(hStack)
        hStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        swatchView.addAction(UIAction { [unowned self] _ in
            self.color = self.swatchView.selectedColor
            self.sendActions(for: [.valueChanged, .primaryActionTriggered])
        }, for: .primaryActionTriggered)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
}

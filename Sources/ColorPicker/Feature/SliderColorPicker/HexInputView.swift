import UIKit

class HexInputView: UIControl {
    var color: HSVA {
        get {
            ColorFormatter().color(from: textField.text!) ?? .noop
        }
        set {
            textField.text = ColorFormatter().string(from: newValue)
        }
    }
    
    let textField: UITextField = .init(frame: .null)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        textField.text = "#000000"
        textField.borderStyle = .roundedRect
        textField.textAlignment = .center
        textField.keyboardType = .asciiCapable
        
        let toolbar = UIToolbar()
        let doneAction = UIAction { [unowned self] _ in
            self.endEditing(false)
        }
        let doneButton = UIBarButtonItem(systemItem: .done, primaryAction: doneAction)
        toolbar.setItems([.flexibleSpace(), doneButton], animated: false)
        toolbar.sizeToFit()
        textField.inputAccessoryView = toolbar
        
        let hStack = UIStackView(arrangedSubviews: [UIView(), textField])
        addSubview(hStack)
        hStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        textField.snp.makeConstraints { make in
            make.width.equalTo(96)
        }
        
        textField.addAction(UIAction { [unowned self] _ in
            self.color = ColorFormatter().color(from: textField.text!) ?? .noop
            self.sendActions(for: [.editingDidEnd, .primaryActionTriggered])
        }, for: .editingDidEnd)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


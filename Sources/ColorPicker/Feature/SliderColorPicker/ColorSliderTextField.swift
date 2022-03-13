import UIKit

struct ColorSliderTextFieldConfiguration {
    let textToValue: (String) -> Double
    let valueToText: (Double) -> String
}

extension ColorSliderTextFieldConfiguration {
    static var hex: Self = .init(
        textToValue: { text in
            (Double(text) ?? 0) / 255.0
        },
        valueToText: { value in
            "\(Int(value * 255.0))"
        }
    )
    
    static var radius: Self = .init(
        textToValue: { text in
            (Double(text) ?? 0) / 360.0
        },
        valueToText: { value in
            "\(Int(value * 360.0))"
        }
    )
    
    static var percent: Self = .init(
        textToValue: { text in
            (Double(text) ?? 0) / 100.0
        },
        valueToText: { value in
            "\(Int(value * 100.0))"
        }
    )
}

class ColorSliderTextField: UITextField {
    var configuration: ColorSliderTextFieldConfiguration!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        text = "0"
        borderStyle = .roundedRect
        textAlignment = .center
        keyboardType = .numberPad
        
        let toolbar = UIToolbar()
        let doneAction = UIAction { [unowned self] _ in
            self.endEditing(false)
        }
        let doneButton = UIBarButtonItem(systemItem: .done, primaryAction: doneAction)
        toolbar.setItems([.flexibleSpace(), doneButton], animated: false)
        toolbar.sizeToFit()
        inputAccessoryView = toolbar
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var value: Double {
        get { configuration.textToValue(text!) }
        set { text = configuration.valueToText(newValue) }
    }
}

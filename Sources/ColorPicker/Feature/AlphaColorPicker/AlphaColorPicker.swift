import UIKit

public class AlphaColorPicker: UIControl {
    public let id: String = #function
    public var title: String = ""
    
    let alphaSlider = ColorSliderWithInputView()
    
    private var _color: CGColor = .white
    
    public var color: CGColor {
        get { _color }
        set {
            guard _color != newValue else { return }
            _color = newValue
            alphaSlider.color = newValue
        }
    }
    
    public var continuously: Bool {
        alphaSlider.slider.panGestureRecognizer.state == .changed
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        alphaSlider.slider.configuration = .alpha
        alphaSlider.textField.configuration = .percent
        alphaSlider.titleLabel.text = "不透明度"
        
        let vStack = UIStackView(arrangedSubviews: [alphaSlider])
        vStack.axis = .vertical
        addSubview(vStack)
        
        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let valueSyncAction = UIAction { [unowned self] action in
            let slider = (action.sender as! ColorSliderWithInputView).slider
            self.color = slider.color
            self.sendActions(for: [.valueChanged, .primaryActionTriggered])
        }
        alphaSlider.addAction(valueSyncAction, for: .primaryActionTriggered)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
}

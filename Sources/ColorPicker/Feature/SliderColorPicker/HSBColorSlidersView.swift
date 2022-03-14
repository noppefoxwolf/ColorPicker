import UIKit

class HSBColorSlidersView: UIControl {
    let hueSlider = ColorSliderWithInputView()
    let saturationSlider = ColorSliderWithInputView()
    let brightnessSlider = ColorSliderWithInputView()
    
    private var _color: UIColor = .white
    
    var color: UIColor {
        get { _color }
        set {
            _color = newValue
            hueSlider.color = newValue
            saturationSlider.color = newValue
            brightnessSlider.color = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        hueSlider.slider.configuration = .hue
        hueSlider.textField.configuration = .radius
        hueSlider.titleLabel.text = LocalizedString.hue
        
        saturationSlider.slider.configuration = .saturation
        saturationSlider.textField.configuration = .percent
        saturationSlider.titleLabel.text = LocalizedString.saturation
        
        brightnessSlider.slider.configuration = .brightness
        brightnessSlider.textField.configuration = .percent
        brightnessSlider.titleLabel.text = LocalizedString.brightness
        
        let vStack = UIStackView(arrangedSubviews: [hueSlider, saturationSlider, brightnessSlider])
        vStack.axis = .vertical
        vStack.spacing = 16
        addSubview(vStack)
        
        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let valueSyncAction = UIAction { action in
            let slider = (action.sender as! ColorSliderWithInputView).slider
            self.color = slider.color
            self.sendActions(for: [.valueChanged, .primaryActionTriggered])
        }
        hueSlider.addAction(valueSyncAction, for: .primaryActionTriggered)
        saturationSlider.addAction(valueSyncAction, for: .primaryActionTriggered)
        brightnessSlider.addAction(valueSyncAction, for: .primaryActionTriggered)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


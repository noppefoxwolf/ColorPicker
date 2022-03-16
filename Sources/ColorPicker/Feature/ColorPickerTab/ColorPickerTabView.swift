import UIKit

class ColorPickerTabView: UIControl {
    let segmentControl = UISegmentedControl(items: [
        LocalizedString.grid,
        LocalizedString.classic,
        LocalizedString.sliders
    ])
    let sliderColorPicker = SliderColorPicker(frame: .null)
    let classicColorPicker = ClassicColorPicker(frame: .null)
    let gridColorPicker = GridColorPicker(frame: .null)
    let scrollView = UIScrollView(frame: .null)
    let vStack: UIStackView = UIStackView()
    
    enum SegmentItem: Int {
        case grid
        case classic
        case slider
    }
    
    private var _color: UIColor = .white
    
    var color: UIColor {
        get { _color }
        set {
            _color = newValue
            sliderColorPicker.color = newValue
            classicColorPicker.color = newValue
            gridColorPicker.color = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        keyboardLayoutGuide.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom)
        }
        
        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        vStack.axis = .vertical
        vStack.spacing = 26
        contentView.addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(16)
        }
        vStack.addArrangedSubview(segmentControl)
        
        segmentControl.addAction(UIAction { [unowned self] action in
            let segmentControl = (action.sender as! UISegmentedControl)
            self.replaceView(SegmentItem(rawValue: segmentControl.selectedSegmentIndex)!)
        }, for: .primaryActionTriggered)
        
        gridColorPicker.addAction(UIAction { [unowned self] _ in
            self.color = self.gridColorPicker.color
            self.sendActions(for: [.primaryActionTriggered, .valueChanged])
        }, for: .primaryActionTriggered)
        
        classicColorPicker.addAction(UIAction { [unowned self] _ in
            self.color = self.classicColorPicker.color
            self.sendActions(for: [.primaryActionTriggered, .valueChanged])
        }, for: .primaryActionTriggered)
        
        sliderColorPicker.addAction(UIAction { [unowned self] _ in
            self.color = self.sliderColorPicker.color
            self.sendActions(for: [.primaryActionTriggered, .valueChanged])
        }, for: .primaryActionTriggered)
        
        segmentControl.selectedSegmentIndex = 0
        
        replaceView(.grid)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    func replaceView(_ item: SegmentItem) {
        vStack
            .arrangedSubviews
            .filter({ !($0 is UISegmentedControl) })
            .forEach({ $0.removeFromSuperview() })
        switch item {
        case .grid:
            vStack.addArrangedSubview(gridColorPicker)
            // layout next frame
            DispatchQueue.main.async { [weak self] in
                self?.gridColorPicker.setNeedsUpdateConstraints()
            }
        case .classic:
            vStack.addArrangedSubview(classicColorPicker)
            // layout next frame
            DispatchQueue.main.async { [weak self] in
                self?.classicColorPicker.setNeedsUpdateConstraints()
            }
        case .slider:
            vStack.addArrangedSubview(sliderColorPicker)
            // layout next frame
            DispatchQueue.main.async { [weak self] in
                self?.sliderColorPicker.setNeedsUpdateConstraints()
            }
        }
    }
}

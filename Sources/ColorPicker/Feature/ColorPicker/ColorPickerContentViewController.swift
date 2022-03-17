import UIKit
import SwiftUI

protocol ColorPickerContentViewControllerDelegate: AnyObject {
    func colorPickerViewController(_ viewController: ColorPickerContentViewController, didSelect color: UIColor, continuously: Bool)
    func colorPickerViewControllerDidFinish(_ viewController: ColorPickerContentViewController)
}

class ColorPickerContentViewController: UIViewController {
    weak var delegate: ColorPickerContentViewControllerDelegate? = nil
    let scrollView = UIScrollView()
    let segmentControl = UISegmentedControl(items: nil)
    let colorPickers: [UIControl & ColorPicker] = [
        GridColorPicker(frame: .null),
        ClassicColorPicker(frame: .null),
        SliderColorPicker(frame: .null),
    ]
    let swatchAndPreviewView = SwatchAndPreviewView(frame: .null)
    
    /// segment - colorPickerAndSwatch
    let tabStackView: UIStackView = UIStackView()
    /// colorPicker - Swatch
    let colorPickersStackView = UIStackView()
    
    private var _color: UIColor = .white {
        didSet {
            swatchAndPreviewView.color = _color
            colorPickers.forEach({ $0.color = _color })
        }
    }
    
    var color: UIColor {
        get { _color }
        set {
            guard _color != newValue else { return }
            _color = newValue
        }
    }
    
    var continuously: Bool {
        colorPickers.map(\.continuously).contains(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.backgroundColor = .secondarySystemBackground
        navigationItem.title = LocalizedString.color
        navigationItem.largeTitleDisplayMode = .always
        
        // unimplemented
        //        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "eyedropper"))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .close, primaryAction: UIAction { [unowned self] _ in
            self.dismiss(animated: true) {
                self.delegate?.colorPickerViewControllerDidFinish(self)
            }
        })
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        view.keyboardLayoutGuide.snp.makeConstraints { make in
            make.top.equalTo(scrollView.snp.bottom)
        }
        
        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        let hairlineView = HairlineView()
        let swatchStack = UIStackView(arrangedSubviews: [hairlineView, swatchAndPreviewView])
        swatchStack.axis = .vertical
        swatchStack.spacing = 20
        
        colorPickersStackView.spacing = 26
        colorPickersStackView.addArrangedSubview(tabStackView)
        colorPickersStackView.addArrangedSubview(swatchStack)
        colorPickersStackView.axis = .vertical
        
        tabStackView.axis = .vertical
        tabStackView.spacing = 26
        tabStackView.layoutMargins = .init(top: 20, left: 20, bottom: 20, right: 20)
        tabStackView.isLayoutMarginsRelativeArrangement = true
        contentView.addSubview(tabStackView)
        tabStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        tabStackView.addArrangedSubview(segmentControl)
        tabStackView.addArrangedSubview(colorPickersStackView)
        
        for colorPicker in colorPickers {
            let segmentAction = UIAction(
                title: colorPicker.title,
                handler: { [unowned self] action in
                    let segmentControl = (action.sender as! UISegmentedControl)
                    self.replaceView(segmentControl.selectedSegmentIndex)
                }
            )
            segmentControl.insertSegment(
                action: segmentAction,
                at: segmentControl.numberOfSegments + 1,
                animated: false
            )
            
            let colorPickerAction = UIAction { [unowned self] _ in
                self.color = colorPicker.color
                self.delegate?.colorPickerViewController(
                    self,
                    didSelect: self.color,
                    continuously: self.continuously
                )
            }
            colorPicker.addAction(colorPickerAction, for: .primaryActionTriggered)
        }
        
        swatchAndPreviewView.addAction(UIAction { [unowned self] _ in
            self.color = self.swatchAndPreviewView.color
            self.delegate?.colorPickerViewController(
                self,
                didSelect: self.color,
                continuously: false
            )
        }, for: .primaryActionTriggered)
        
        segmentControl.selectedSegmentIndex = 0
        updateCurrentColorPicker()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        switch (traitCollection.horizontalSizeClass, traitCollection.verticalSizeClass) {
        case (.compact, .compact): // iPhone landscape
            colorPickersStackView.axis = .horizontal
            colorPickersStackView.distribution = .fillEqually
        default:
            colorPickersStackView.axis = .vertical
            colorPickersStackView.distribution = .fill
        }
    }
    
    func updateCurrentColorPicker() {
        let index = segmentControl.selectedSegmentIndex
        colorPickersStackView
            .arrangedSubviews
            .filter({ ($0 is ColorPicker) })
            .forEach({ $0.removeFromSuperview() })
        colorPickersStackView.insertArrangedSubview(colorPickers[index], at: 0)
    }
}

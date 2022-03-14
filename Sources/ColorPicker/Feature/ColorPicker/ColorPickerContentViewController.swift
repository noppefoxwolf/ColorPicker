import UIKit
import SwiftUI

protocol ColorPickerContentViewControllerDelegate: AnyObject {
    func colorPickerViewController(_ viewController: ColorPickerContentViewController, didSelect color: UIColor, continuously: Bool)
    func colorPickerViewControllerDidFinish(_ viewController: ColorPickerContentViewController)
}

class ColorPickerContentViewController: UIViewController {
    let colorPickerTabView = ColorPickerTabView(frame: .null)
    let swatchAndPreviewView = SwatchAndPreviewView(frame: .null)
    weak var delegate: ColorPickerContentViewControllerDelegate? = nil
    
    private var _color: UIColor = .white
    
    var color: UIColor {
        get { _color }
        set {
            _color = newValue
            swatchAndPreviewView.color = newValue
            colorPickerTabView.color = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationItem.title = LocalizedString.color
        navigationItem.largeTitleDisplayMode = .always
        
        // unimplemented
//        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "eyedropper"))
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .close, primaryAction: UIAction { [unowned self] _ in
            self.dismiss(animated: true) {
                self.delegate?.colorPickerViewControllerDidFinish(self)
            }
        })
        
        view.addSubview(colorPickerTabView)
        
        let hairlineView = HairlineView()
        let vStack = UIStackView(arrangedSubviews: [hairlineView, swatchAndPreviewView])
        vStack.axis = .vertical
        vStack.spacing = 20
        view.addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        colorPickerTabView.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(vStack.snp.top)
        }
        
        colorPickerTabView.addAction(UIAction { [unowned self] _ in
            self.color = self.colorPickerTabView.color
            self.delegate?.colorPickerViewController(self, didSelect: self.color, continuously: true)
        }, for: .primaryActionTriggered)
        
        swatchAndPreviewView.addAction(UIAction { [unowned self] _ in
            self.color = self.swatchAndPreviewView.color
            self.delegate?.colorPickerViewController(self, didSelect: self.color, continuously: true)
        }, for: .primaryActionTriggered)
    }
}

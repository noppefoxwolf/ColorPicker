import UIKit

public protocol ColorPickerViewControllerDelegate: AnyObject {
    func colorPickerViewController(_ viewController: ColorPickerViewController, didSelect color: CGColor, continuously: Bool)
    func colorPickerViewControllerDidFinish(_ viewController: ColorPickerViewController)
}

public protocol ColorPickerViewControllerSwatchDelegate: AnyObject {
    func colorPickerViewControllerSwatchDidChanged(_ viewController: ColorPickerViewController)
}

public protocol ColorPickerViewControllerActionDelegate: AnyObject {
    func colorPickerViewControllerDidSelectScreenColorPicker(_ viewController: ColorPickerViewController)
}

public class ColorPickerViewController: UINavigationController {
    public init() {
        let vc = ColorPickerContentViewController()
        super.init(rootViewController: vc)
        vc.delegate = self
    }
    
    var contentViewController: ColorPickerContentViewController {
        viewControllers[0] as! ColorPickerContentViewController
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public var selectedColor: CGColor {
        get { contentViewController.color }
        set { contentViewController.color = newValue }
    }
    
    public var colorItems: [ColorItem] {
        get { contentViewController.colorItems }
        set { contentViewController.colorItems = newValue }
    }
    
    public var configuration: ColorPickerConfiguration {
        get { contentViewController.configuration }
        set { contentViewController.configuration = newValue }
    }
    
    private weak var _delegate: ColorPickerViewControllerDelegate? = nil
    public weak var swatchDelegate: ColorPickerViewControllerSwatchDelegate? = nil
    public weak var actionDelegate: ColorPickerViewControllerActionDelegate? = nil
    
    public func setDelegate(_ delegate: ColorPickerViewControllerDelegate) {
        _delegate = delegate
    }
}

extension ColorPickerViewController: ColorPickerContentViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: ColorPickerContentViewController) {
        _delegate?.colorPickerViewControllerDidFinish(self)
    }
    
    func colorPickerViewController(_ viewController: ColorPickerContentViewController, didSelect color: CGColor, continuously: Bool) {
        _delegate?.colorPickerViewController(self, didSelect: color, continuously: continuously)
    }
    
    func colorPickerSwatchDidChanged(_ viewController: ColorPickerContentViewController) {
        swatchDelegate?.colorPickerViewControllerSwatchDidChanged(self)
    }
    
    func colorPickerDropperDidSelect(_ viewController: ColorPickerContentViewController) {
        actionDelegate?.colorPickerViewControllerDidSelectScreenColorPicker(self)
    }
}

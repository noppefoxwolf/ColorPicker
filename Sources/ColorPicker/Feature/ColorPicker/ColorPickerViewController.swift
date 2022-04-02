import UIKit

public protocol ColorPickerViewControllerDelegate: AnyObject {
    func colorPickerViewController(_ viewController: ColorPickerViewController, didSelect color: UIColor, continuously: Bool)
    func colorPickerViewControllerDidFinish(_ viewController: ColorPickerViewController)
}

public protocol ColorPickerViewControllerSwatchDelegate: AnyObject {
    func colorPickerViewControllerSwatchDidChanged(_ viewController: ColorPickerViewController)
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
    
    public var selectedColor: UIColor {
        get { contentViewController.color }
        set { contentViewController.color = newValue }
    }
    
    public var colorItems: [ColorItem] {
        contentViewController.colorItems
    }
    
    public var configuration: ColorPickerConfiguration {
        get { contentViewController.configuration }
        set { contentViewController.configuration = newValue }
    }
    
    private weak var _delegate: ColorPickerViewControllerDelegate? = nil
    public weak var swatchDelegate: ColorPickerViewControllerSwatchDelegate? = nil
    
    public func setDelegate(_ delegate: ColorPickerViewControllerDelegate) {
        _delegate = delegate
    }
}

extension ColorPickerViewController: ColorPickerContentViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: ColorPickerContentViewController) {
        _delegate?.colorPickerViewControllerDidFinish(self)
    }
    
    func colorPickerViewController(_ viewController: ColorPickerContentViewController, didSelect color: UIColor, continuously: Bool) {
        _delegate?.colorPickerViewController(self, didSelect: color, continuously: continuously)
    }
    
    func colorPickerSwatchDidChanged(_ viewController: ColorPickerContentViewController) {
        swatchDelegate?.colorPickerViewControllerSwatchDidChanged(self)
    }
}

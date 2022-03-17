import SwiftUI
import ColorPicker
import SnapKit

struct ContentView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        ContentViewController()
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}

class ContentViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let colorPickerButton = UIButton(primaryAction: UIAction(title: "noppefoxwolf/ColorPicker", handler: { _ in
            let vc = ColorPickerViewController()
            vc.setDelegate(self)
            self.present(vc, animated: true)
        }))
        let uiColorPickerButton = UIButton(primaryAction: UIAction(title: "apple/UIColorPicker", handler: { _ in
            let vc = UIColorPickerViewController()
            vc.delegate = self
            self.present(vc, animated: true)
        }))
        let stackView = UIStackView(arrangedSubviews: [colorPickerButton, uiColorPickerButton])
        stackView.axis = .vertical
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}

extension ContentViewController: ColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: ColorPickerViewController) {
        print(#function, viewController.selectedColor)
    }
    
    func colorPickerViewController(_ viewController: ColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        print(#function, color, continuously)
    }
}

extension ContentViewController: UIColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: UIColorPickerViewController) {
        print(#function, viewController.selectedColor)
    }
    
    func colorPickerViewController(_ viewController: UIColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        print(#function, color, continuously)
    }
}

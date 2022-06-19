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
            self.presentColorPicker(
                CGColor(red: 1, green: 0, blue: 0, alpha: 1)
            )
        }))
        let uiColorPickerButton = UIButton(primaryAction: UIAction(title: "apple/UIColorPicker", handler: { _ in
            let vc = UIColorPickerViewController()
            vc.supportsAlpha = false
            vc.delegate = self
            self.present(vc, animated: true)
        }))
        let imageView = UIImageView(image: UIImage(named: "image"))
        imageView.contentMode = .scaleAspectFit
        let stackView = UIStackView(arrangedSubviews: [
            imageView,
            colorPickerButton,
            uiColorPickerButton
        ])
        stackView.axis = .vertical
        view.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        imageView.snp.makeConstraints { make in
            make.size.equalTo(260)
        }
    }
    
    func presentColorPicker(_ color: CGColor) {
        let vc = ColorPickerViewController()
        let configuration = ColorPickerConfiguration.default
        configuration.initialColor = color
        configuration.initialColorItems = [
            .init(id: UUID(), color: CGColor(red: 1, green: 0, blue: 0, alpha: 1))
        ]
        vc.configuration = configuration
        vc.setDelegate(self)
        vc.actionDelegate = self
        present(vc, animated: true)
    }
}

extension ContentViewController: ColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: ColorPickerViewController) {
        print(#function, viewController.selectedColor)
    }
    
    func colorPickerViewController(_ viewController: ColorPickerViewController, didSelect color: CGColor, continuously: Bool) {
        print(#function, color, continuously)
    }
}

extension ContentViewController: ColorPickerViewControllerSwatchDelegate {
    func colorPickerViewControllerSwatchDidChanged(_ viewController: ColorPickerViewController) {
        print(#function)
    }
}

extension ContentViewController: ColorPickerViewControllerActionDelegate {
    func colorPickerViewControllerDidSelectScreenColorPicker(_ viewController: ColorPickerViewController) {
        viewController.dismiss(animated: true)
        
        let scenes = UIApplication.shared.connectedScenes
        let windowScenes = scenes.compactMap({ $0 as? UIWindowScene })
        if let windowScene = windowScenes.first(where: { $0.activationState == .foregroundActive }) {
            let picker = ScopeColorPicker(windowScene: windowScene)
            Task {
                let color = await picker.pickColor()
                viewController.selectedColor = color
                present(viewController, animated: true)
            }
        }
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

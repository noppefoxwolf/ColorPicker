import ColorPicker
import Combine
import SwiftUI

struct ContentView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        ContentViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
}

class ContentViewController: UIViewController {
    var cancellables: Set<AnyCancellable> = []

    override func viewDidLoad() {
        super.viewDidLoad()

        let colorPickerButton = UIButton(
            primaryAction: UIAction(
                title: "noppefoxwolf/ColorPicker",
                handler: { _ in
                    self.presentColorPicker(
                        UIColor(red: 1, green: 0, blue: 0, alpha: 0.5)
                    )
                }
            )
        )
        let uiColorPickerButton = UIButton(
            primaryAction: UIAction(
                title: "apple/UIColorPicker",
                handler: { _ in
                    self.presentUIColorPicker()
                }
            )
        )
        let imageView = UIImageView(image: UIImage(named: "image"))
        imageView.contentMode = .scaleAspectFit
        let eyeDropperButton = UIButton(configuration: .filled())
        eyeDropperButton.configuration?.image = UIImage(systemName: "eyedropper")
        eyeDropperButton.configuration?.title = "Tap or drag here"
        eyeDropperButton.addAction(
            UIAction { [unowned self] _ in
                let picker = ScopeColorPicker(windowScene: self.view.window!.windowScene!)
                Task {
                    let color = await picker.pickColor()
                    print(color)
                }
            },
            for: .primaryActionTriggered
        )

        let goOut = GoOutPanGestureRecognizer()
        goOut
            .publisher(for: \.state)
            .filter({ $0 == .began })
            .sink { [unowned self] state in
                let picker = ScopeColorPicker(
                    windowScene: self.view.window!.windowScene!,
                    gestureRecognizer: goOut
                )
                Task {
                    let color = await picker.pickColor()
                    print(color)
                }
            }
            .store(in: &cancellables)
        eyeDropperButton.addGestureRecognizer(goOut)

        let longpress = UILongPressGestureRecognizer()
        longpress.publisher(for: \.state)
            .filter({ $0 == .began })
            .sink { [unowned self] state in
                let picker = ScopeColorPicker(
                    windowScene: self.view.window!.windowScene!,
                    gestureRecognizer: longpress
                )
                Task {
                    let color = await picker.pickColor()
                    print(color)
                }
            }
            .store(in: &cancellables)
        imageView.addGestureRecognizer(longpress)
        imageView.isUserInteractionEnabled = true

        let stackView = UIStackView(arrangedSubviews: [
            imageView,
            colorPickerButton,
            uiColorPickerButton,
            eyeDropperButton,
        ])
        stackView.axis = .vertical
        view.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 260),
            imageView.heightAnchor.constraint(equalToConstant: 260),
        ])
    }

    func presentColorPicker(_ color: UIColor) {
        let vc = ColorPickerViewController()
        vc.supportsAlpha = true
        var configuration = ColorPickerConfiguration.default
        configuration.initialColorItems = [
            .init(id: UUID(), color: HSVA(UIColor(red: 1, green: 0, blue: 0, alpha: 1))),
            .init(id: UUID(), color: HSVA(UIColor(red: 0, green: 1, blue: 0, alpha: 1))),
            .init(id: UUID(), color: HSVA(UIColor(red: 0, green: 0, blue: 1, alpha: 1))),
        ]
        //        configuration.colorPickers = [HSBHexSliderColorPicker(frame: .null)]
        //        configuration.usesSwatchTool = false
        //        configuration.usesDropperTool = false
        vc.selectedColor = color
        vc.configuration = configuration
        vc.setDelegate(self)
        vc.actionDelegate = self
        present(vc, animated: true)
    }

    func presentUIColorPicker() {
        let vc = UIColorPickerViewController()
        vc.selectedColor = .red
        vc.supportsAlpha = true
        vc.delegate = self
        self.present(vc, animated: true)
    }
}

extension ContentViewController: ColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: ColorPickerViewController) {
        print(#function, viewController.selectedColor)
    }

    func colorPickerViewController(
        _ viewController: ColorPickerViewController,
        didSelect color: UIColor,
        continuously: Bool
    ) {
        print(#function, color, continuously)
    }
}

extension ContentViewController: ColorPickerViewControllerSwatchDelegate {
    func colorPickerViewControllerSwatchDidChanged(_ viewController: ColorPickerViewController) {
        print(#function)
    }
}

extension ContentViewController: ColorPickerViewControllerActionDelegate {
    func colorPickerViewControllerDidSelectScreenColorPicker(
        _ viewController: ColorPickerViewController
    ) {
        viewController.dismiss(animated: true)

        let scenes = UIApplication.shared.connectedScenes
        let windowScenes = scenes.compactMap({ $0 as? UIWindowScene })
        if let windowScene = windowScenes.first(where: { $0.activationState == .foregroundActive })
        {
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

    func colorPickerViewController(
        _ viewController: UIColorPickerViewController,
        didSelect color: UIColor,
        continuously: Bool
    ) {
        print(#function, color, continuously)
    }
}

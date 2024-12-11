# ColorPicker

`ColorPicker` is a UI component for pick a color.

![](https://github.com/henzai-apps/ColorPicker/blob/main/.github/Helo.jpeg)

# Requirements

- Swift5.6

- iOS15

# Installation

[Adding Package Dependencies to Your App](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app)

# Getting Started

## Present ColorPicker

```swift
import ColorPicker
...
let vc = ColorPickerViewController()
vc.setDelegate(self)
present(vc, animated: true)
```

## Customize swatch colors

```swift
let vc = ColorPickerViewController()
var configuration = ColorPickerConfiguration.default
configuration.initialColor = .red
configuration.initialColorItems = [.init(id: UUID(), color: .red)]
vc.configuration = configuration
vc.setDelegate(self)
present(vc, animated: true)
```

## Handle changed color

```swift
extension ContentViewController: ColorPickerViewControllerDelegate {
    func colorPickerViewControllerDidFinish(_ viewController: ColorPickerViewController) {
        print(#function, viewController.selectedColor)
    }
    
    func colorPickerViewController(_ viewController: ColorPickerViewController, didSelect color: UIColor, continuously: Bool) {
        print(#function, color, continuously)
    }
}
```

# Apps using ColorPicker

- [WebSSH - SysAdmin Tools](https://apps.apple.com/us/app/webssh-sysadmin-tools/id497714887)
- [Editormode](https://apps.apple.com/jp/app/%E3%83%89%E3%83%83%E3%83%88%E7%B5%B5%E3%83%A1%E3%83%BC%E3%82%AB%E3%83%BC-editormode/id1586258429)

# Maintainer

[@noppefoxwolf](https://twitter.com/noppefoxwolf)

# License

ColorPicker is available under the MIT license. See the LICENSE file for more info.

# Prohibited matter 🚫

Forking or contributing in order to disguise the activity of spam accounts as legitimate accounts is prohibited.
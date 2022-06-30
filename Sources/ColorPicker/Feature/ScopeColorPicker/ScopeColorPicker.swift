import UIKit

public class ScopeColorPicker {
    let pickerWindow: ScopeColorPickerWindow
    var continuation: CheckedContinuation<CGColor, Never>? = nil
    
    public init(
        windowScene: UIWindowScene,
        panGestureRecognizer: UIPanGestureRecognizer? = nil
    ) {
        self.pickerWindow = .init(windowScene: windowScene, panGestureRecognizer: panGestureRecognizer)
        pickerWindow.delegate = self
        pickerWindow.dataSource = self
    }
    
    public func pickColor() async -> CGColor {
        await withCheckedContinuation { [weak self] continuation in
            self?.continuation = continuation
        }
    }
}

extension ScopeColorPicker: ScopeColorPickerDelegate {
    func scopePickerDidFinishColorPick(_ color: CGColor) {
        continuation?.resume(with: .success(color))
    }
}

extension ScopeColorPicker: ScopeColorPickerDataSource {
    func colors(at location: CGPoint, context: CGContext) {
        let keyWindow = pickerWindow.windowScene!.keyWindow!
        context.translateBy(x: -location.x, y: -location.y)
        keyWindow.layer.render(in: context)
    }
}

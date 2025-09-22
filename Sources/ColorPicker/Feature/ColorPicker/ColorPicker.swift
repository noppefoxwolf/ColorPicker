import UIKit

public protocol ColorPicker: Sendable {
    var id: String { get }
    var title: String { get }
    
    associatedtype ColorPickerControl: UIControl & ColorPickerView
    
    @MainActor
    func makeUIControl(_ color: HSVA) -> ColorPickerControl
    
    @MainActor
    func updateUIControl(_ uiView: ColorPickerControl, color: HSVA)
}

@MainActor
public protocol ColorPickerView: AnyObject {
    var color: HSVA { get set }
    var continuously: Bool { get }
}


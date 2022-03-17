import UIKit

public struct ColorPickerConfiguration {
    public static let `default`: ColorPickerConfiguration = .init()
    
    public var initialColor: UIColor = .white
    
    public var colorPickers: [UIControl & ColorPicker] = [
        GridColorPicker(frame: .null),
        ClassicColorPicker(frame: .null),
        SliderColorPicker(frame: .null),
    ]
    
    public var initialColorItems: [ColorItem] = []
}

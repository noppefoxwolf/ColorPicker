import UIKit

public class ColorPickerConfiguration {
    public static var `default`: ColorPickerConfiguration { ColorPickerConfiguration() }
    
    public var initialColor: UIColor = .white
    
    public var colorPickers: [UIControl & ColorPicker] = [
        GridColorPicker(frame: .null),
        ClassicColorPicker(frame: .null),
        SliderColorPicker(frame: .null),
    ]
    
    public var initialColorItems: [ColorItem] = []
}

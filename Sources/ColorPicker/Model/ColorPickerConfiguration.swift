import UIKit

public struct ColorPickerConfiguration {
    public static var `default`: ColorPickerConfiguration { ColorPickerConfiguration() }
    
    public var colorPickers: [any ColorPicker] = [
        RGBColorSliderColorPicker(),
        GridColorPicker(),
        ClassicColorPicker(),
        RGBHexSliderColorPicker(),
        HSBColorSliderColorPicker(),
    ]

    public var initialColorItems: [ColorItem]? = nil

    public var usesSwatchTool: Bool = true

    public var usesDropperTool: Bool = true
}

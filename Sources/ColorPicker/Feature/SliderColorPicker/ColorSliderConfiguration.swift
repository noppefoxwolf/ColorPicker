import UIKit

struct ColorSliderConfiguration {
    let gradientInvalidationHandler: (UIColor) -> CGGradient
    let colorToValue: (UIColor) -> Double
    let valueToColor: (Double, UIColor) -> UIColor
}

extension ColorSliderConfiguration {
    static var noop: Self = .init { _ in
        fatalError()
    } colorToValue: { _ in
        0
    } valueToColor: { _, _ in
        .white
    }
    
    static var red: Self = .init(
        gradientInvalidationHandler: { color in
            var green: CGFloat = 0
            var blue: CGFloat = 0
            color.getRed(nil, green: &green, blue: &blue, alpha: nil)
            return CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    // Use sRBG
                    UIColor(red: 0, green: green, blue: blue, alpha: 1).cgColor,
                    UIColor(red: 1, green: green, blue: blue, alpha: 1).cgColor,
                ] as CFArray,
                locations: [0, 1]
            )!
        },
        colorToValue: { color in
            var red: CGFloat = 0
            color.getRed(&red, green: nil, blue: nil, alpha: nil)
            return red
        },
        valueToColor: { (value, color) in
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            color.getRed(nil, green: &green, blue: &blue, alpha: &alpha)
            return UIColor(red: value, green: green, blue: blue, alpha: alpha)
        }
    )
    
    static var green: Self = .init(
        gradientInvalidationHandler: { color in
            var red: CGFloat = 0
            var blue: CGFloat = 0
            color.getRed(&red, green: nil, blue: &blue, alpha: nil)
            return CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    // Use sRBG
                    UIColor(red: red, green: 0, blue: blue, alpha: 1).cgColor,
                    UIColor(red: red, green: 1, blue: blue, alpha: 1).cgColor,
                ] as CFArray,
                locations: [0, 1]
            )!
        },
        colorToValue: { color in
            var green: CGFloat = 0
            color.getRed(nil, green: &green, blue: nil, alpha: nil)
            return green
        },
        valueToColor: { (value, color) in
            var red: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            color.getRed(&red, green: nil, blue: &blue, alpha: &alpha)
            return UIColor(red: red, green: value, blue: blue, alpha: alpha)
        }
    )
    
    static var blue: Self = .init(
        gradientInvalidationHandler: { color in
            var red: CGFloat = 0
            var green: CGFloat = 0
            color.getRed(&red, green: &green, blue: nil, alpha: nil)
            return CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    // Use sRBG
                    UIColor(red: red, green: green, blue: 0, alpha: 1).cgColor,
                    UIColor(red: red, green: green, blue: 1, alpha: 1).cgColor,
                ] as CFArray,
                locations: [0, 1]
            )!
        },
        colorToValue: { color in
            var blue: CGFloat = 0
            color.getRed(nil, green: nil, blue: &blue, alpha: nil)
            return blue
        },
        valueToColor: { (value, color) in
            var red: CGFloat = 0
            var green: CGFloat = 0
            var alpha: CGFloat = 0
            color.getRed(&red, green: &green, blue: nil, alpha: &alpha)
            return UIColor(red: red, green: green, blue: value, alpha: alpha)
        }
    )

    static var hue: Self = .init(
        gradientInvalidationHandler: { color in
            let locations = stride(from: 0, to: 1, by: 1.0 / 12.0)
            let colors = locations.map { hue in
                UIColor(
                    hue: hue,
                    saturation: 1,
                    brightness: 1,
                    alpha: 1
                )
            }.map(\.cgColor)
            
            return CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: locations.map({ CGFloat($0) })
            )!
        },
        colorToValue: { color in
            color.hsba.hue
        },
        valueToColor: { (value, color) in
            let (_, saturation, brightness, alpha) = color.hsba
            return UIColor(hue: value, saturation: saturation, brightness: brightness, alpha: alpha)
        }
    )
    
    static var saturation: Self = .init(
        gradientInvalidationHandler: { color in
            let hue: CGFloat = color.hsba.hue
            return CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor(hue: hue, saturation: 0, brightness: 1, alpha: 1).cgColor,
                    UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1).cgColor
                ] as CFArray,
                locations: [0, 1]
            )!
        },
        colorToValue: { color in
            color.hsba.saturation
        },
        valueToColor: { (value, color) in
            let (hue, _, brightness, alpha) = color.hsba
            return UIColor(hue: hue, saturation: value, brightness: brightness, alpha: alpha)
        }
    )
    
    static var brightness: Self = .init(
        gradientInvalidationHandler: { color in
            let (hue, saturation, _, _) = color.hsba
            return CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    UIColor(hue: hue, saturation: saturation, brightness: 0, alpha: 1).cgColor,
                    UIColor(hue: hue, saturation: saturation, brightness: 1, alpha: 1).cgColor
                ] as CFArray,
                locations: [0, 1]
            )!
        },
        colorToValue: { color in
            color.hsba.brightness
        },
        valueToColor: { (value, color) in
            let (hue, saturation, _, alpha) = color.hsba
            return UIColor(hue: hue, saturation: saturation, brightness: value, alpha: alpha)
        }
    )

}

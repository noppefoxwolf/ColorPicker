import UIKit

struct ColorSliderConfiguration {
    let gradientInvalidationHandler: (CGColor) -> CGGradient
    let colorToValue: (CGColor) -> Double
    let valueToColor: (Double, CGColor) -> CGColor
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
            return CGColor(red: value, green: green, blue: blue, alpha: alpha)
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
            return CGColor(red: red, green: value, blue: blue, alpha: alpha)
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
            return CGColor(red: red, green: green, blue: value, alpha: alpha)
        }
    )

    static var hue: Self = .init(
        gradientInvalidationHandler: { color in
            let locations = stride(from: 0, to: 1, by: 1.0 / 12.0)
            let colors = locations.map { hue in
                CGColor.make(
                    hue: hue,
                    saturation: 1,
                    brightness: 1,
                    alpha: 1
                )
            }
            
            return CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: locations.map({ CGFloat($0) })
            )!
        },
        colorToValue: { color in
            color.hsb.h
        },
        valueToColor: { (value, color) in
            let hsb = color.hsb
            return CGColor.make(hue: value, saturation: hsb.s, brightness: hsb.v, alpha: 1)
        }
    )
    
    static var saturation: Self = .init(
        gradientInvalidationHandler: { color in
            let hue: CGFloat = color.hsb.h
            return CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    CGColor.make(hue: hue, saturation: 0, brightness: 1, alpha: 1),
                    CGColor.make(hue: hue, saturation: 1, brightness: 1, alpha: 1)
                ] as CFArray,
                locations: [0, 1]
            )!
        },
        colorToValue: { color in
            color.hsb.s
        },
        valueToColor: { (value, color) in
            let hsb = color.hsb
            return CGColor.make(hue: hsb.h, saturation: value, brightness: hsb.v, alpha: 1)
        }
    )
    
    static var brightness: Self = .init(
        gradientInvalidationHandler: { color in
            let hsb = color.hsb
            return CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    CGColor.make(hue: hsb.h, saturation: hsb.s, brightness: 0, alpha: 1),
                    CGColor.make(hue: hsb.h, saturation: hsb.s, brightness: 1, alpha: 1)
                ] as CFArray,
                locations: [0, 1]
            )!
        },
        colorToValue: { color in
            color.hsb.v
        },
        valueToColor: { (value, color) in
            let hsb = color.hsb
            return CGColor.make(hue: hsb.h, saturation: hsb.s, brightness: value, alpha: 1)
        }
    )
    
    static var alpha: Self = .init(
        gradientInvalidationHandler: { color in
            let hsb = color.hsb
            return CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    CGColor.make(hue: hsb.h, saturation: hsb.s, brightness: hsb.v, alpha: 0),
                    CGColor.make(hue: hsb.h, saturation: hsb.s, brightness: hsb.v, alpha: 1)
                ] as CFArray,
                locations: [0, 1]
            )!
        },
        colorToValue: { color in
            color.alpha
        },
        valueToColor: { (value, color) in
            let hsb = color.hsb
            return CGColor.make(
                hue: hsb.h,
                saturation: hsb.s,
                brightness: hsb.v,
                alpha: value
            )
        }
    )

}

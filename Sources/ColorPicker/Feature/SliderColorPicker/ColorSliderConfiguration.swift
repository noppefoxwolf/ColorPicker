import UIKit

struct ColorSliderConfiguration: Sendable {
    let gradientInvalidationHandler: @Sendable (HSVA) -> CGGradient
    let colorToValue: @Sendable (HSVA) -> Double
    let valueToColor: @Sendable (Double, HSVA) -> HSVA
}

extension ColorSliderConfiguration {
    static let noop: Self = .init { _ in
        fatalError()
    } colorToValue: { _ in
        0
    } valueToColor: { _, _ in
        .noop
    }
    
    static let red: Self = .init(
        gradientInvalidationHandler: { color in
            CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    // Use sRBG
                    UIColor(red: 0, green: color.hsv.rgb.g, blue: color.hsv.rgb.b, alpha: 1).cgColor,
                    UIColor(red: 1, green: color.hsv.rgb.g, blue: color.hsv.rgb.b, alpha: 1).cgColor,
                ] as CFArray,
                locations: [0, 1]
            )!
        },
        colorToValue: { color in
            color.hsv.rgb.r
        },
        valueToColor: { (value, color) in
            let color = color
            var rgb = color.hsv.rgb
            rgb.r = value
            return HSVA(hsv: rgb.hsv, a: color.a)
        }
    )
    
    static let green: Self = .init(
        gradientInvalidationHandler: { color in
            CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    // Use sRBG
                    UIColor(red: color.hsv.rgb.r, green: 0, blue: color.hsv.rgb.b, alpha: 1).cgColor,
                    UIColor(red: color.hsv.rgb.r, green: 1, blue: color.hsv.rgb.b, alpha: 1).cgColor,
                ] as CFArray,
                locations: [0, 1]
            )!
        },
        colorToValue: { color in
            color.hsv.rgb.g
        },
        valueToColor: { (value, color) in
            let color = color
            var rgb = color.hsv.rgb
            rgb.g = value
            return HSVA(hsv: rgb.hsv, a: color.a)
        }
    )
    
    static let blue: Self = .init(
        gradientInvalidationHandler: { color in
            CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    // Use sRBG
                    UIColor(red: color.hsv.rgb.r, green: color.hsv.rgb.g, blue: 0, alpha: 1).cgColor,
                    UIColor(red: color.hsv.rgb.r, green: color.hsv.rgb.g, blue: 1, alpha: 1).cgColor,
                ] as CFArray,
                locations: [0, 1]
            )!
        },
        colorToValue: { color in
            color.hsv.rgb.b
        },
        valueToColor: { (value, color) in
            let color = color
            var rgb = color.hsv.rgb
            rgb.b = value
            return HSVA(hsv: rgb.hsv, a: color.a)
        }
    )

    static let hue: Self = .init(
        gradientInvalidationHandler: { color in
            let locations = stride(from: 0, to: 1, by: 1.0 / 12.0)
            let colors = locations.map { hue in
                HSVA(hsv: HSV(h: hue, s: 1, v: 1), a: 1)
            }.map({ $0.makeColor().cgColor })
            
            return CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: locations.map({ CGFloat($0) })
            )!
        },
        colorToValue: { color in
            color.hsv.h
        },
        valueToColor: { (value, color) in
            var color = color
            color.hsv.h = value
            return color
        }
    )
    
    static let saturation: Self = .init(
        gradientInvalidationHandler: { color in
            let hue: CGFloat = color.hsv.h
            return CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    HSVA(hsv: HSV(h: hue, s: 0, v: 1), a: 1).makeColor().cgColor,
                    HSVA(hsv: HSV(h: hue, s: 1, v: 1), a: 1).makeColor().cgColor,
                ] as CFArray,
                locations: [0, 1]
            )!
        },
        colorToValue: { color in
            color.hsv.s
        },
        valueToColor: { (value, color) in
            var color = color
            color.hsv.s = value
            return color
        }
    )
    
    static let brightness: Self = .init(
        gradientInvalidationHandler: { color in
            let hsv = color.hsv
            return CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    HSVA(hsv: HSV(h: hsv.h, s: hsv.s, v: 0), a: 1).makeColor().cgColor,
                    HSVA(hsv: HSV(h: hsv.h, s: hsv.s, v: 1), a: 1).makeColor().cgColor,
                ] as CFArray,
                locations: [0, 1]
            )!
        },
        colorToValue: { color in
            color.hsv.v
        },
        valueToColor: { (value, color) in
            var color = color
            color.hsv.v = value
            return color
        }
    )
    
    static let alpha: Self = .init(
        gradientInvalidationHandler: { color in
            let hsv = color.hsv
            return CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: [
                    HSVA(hsv: HSV(h: hsv.h, s: hsv.s, v: hsv.v), a: 0).makeColor().cgColor,
                    HSVA(hsv: HSV(h: hsv.h, s: hsv.s, v: hsv.v), a: 1).makeColor().cgColor,
                ] as CFArray,
                locations: [0, 1]
            )!
        },
        colorToValue: { color in
            color.a
        },
        valueToColor: { (value, color) in
            var color = color
            color.a = value
            return color
        }
    )

}

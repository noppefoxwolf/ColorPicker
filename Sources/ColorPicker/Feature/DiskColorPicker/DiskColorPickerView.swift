import UIKit

class DiskColorPickerView: UIView {
    let outerDiskColorView: OuterDiskColorView = .init(frame: .null)
    let innerDiskColorView: InnerDiskColorView = .init(frame: .null)

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear
        addSubview(outerDiskColorView)
        outerDiskColorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            outerDiskColorView.topAnchor.constraint(equalTo: topAnchor),
            outerDiskColorView.leadingAnchor.constraint(equalTo: leadingAnchor),
            outerDiskColorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            outerDiskColorView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        addSubview(innerDiskColorView)
        innerDiskColorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            innerDiskColorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            innerDiskColorView.centerYAnchor.constraint(equalTo: centerYAnchor),
            innerDiskColorView.widthAnchor.constraint(equalToConstant: 250),
            innerDiskColorView.heightAnchor.constraint(equalToConstant: 250)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class InnerDiskColorView: UIView {
    let gradientLayer = CAGradientLayer()

    let maskLayer = CAShapeLayer()
    let maskLayer2 = CAGradientLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.black

        gradientLayer.type = .axial
        gradientLayer.backgroundColor = CGColor(gray: 1, alpha: 1)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.colors = stride(from: 0, to: 1, by: 1.0 / 12.0)
            .map({ sat in
                UIColor(hue: 1, saturation: sat, brightness: 1, alpha: 1).cgColor
            })
        layer.addSublayer(gradientLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        maskLayer.frame = bounds
        maskLayer2.frame = bounds

        maskLayer.path =
            UIBezierPath(
                ovalIn: CGRect(
                    origin: .zero,
                    size: bounds.size
                )
            )
            .cgPath
    }
}

class OuterDiskColorView: UIView {
    let gradientLayer = CAGradientLayer()
    let maskLayer = CAShapeLayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.clear

        gradientLayer.type = .conic
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.colors = stride(from: 0, to: 1, by: 1.0 / 20.0)
            .map({ hue in
                UIColor(hue: hue, saturation: 1, brightness: 1, alpha: 1).cgColor
            })
            .reversed()
        layer.addSublayer(gradientLayer)

        gradientLayer.mask = maskLayer
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        maskLayer.frame = bounds

        let combined = UIBezierPath()
        combined.append(
            UIBezierPath(
                ovalIn: CGRect(
                    origin: .zero,
                    size: bounds.size
                )
            )
        )
        let lineWidth = 44
        let scale = (bounds.size.width - CGFloat(lineWidth * 2)) / bounds.size.width
        combined.append(
            UIBezierPath(
                ovalIn: CGRect(
                    origin: CGPoint(x: lineWidth, y: lineWidth),
                    size: bounds.size.applying(CGAffineTransform(scaleX: scale, y: scale))
                )
            )
            .reversing()
        )
        maskLayer.path = combined.cgPath
    }
}

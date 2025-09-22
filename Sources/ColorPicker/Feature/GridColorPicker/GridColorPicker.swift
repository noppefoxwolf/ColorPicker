import UIKit

public struct GridColorPicker: ColorPicker {
    public let id: String = #function
    public let title: String = LocalizedString.grid

    public init() {}

    public func makeUIControl(_ color: HSVA) -> GridColorPickerView {
        GridColorPickerView(frame: .null)
    }

    public func updateUIControl(_ uiView: GridColorPickerView, color: HSVA) {
        uiView.color = color
    }
}

public final class GridColorPickerView: UIControl, ColorPickerView {
    let gridColorView: GridColorView = .init(frame: .null)
    let markerView: GridColorMarkerView = .init(frame: .null)
    private var markerLeftConstraint: NSLayoutConstraint? = nil
    private var markerTopConstraint: NSLayoutConstraint? = nil
    private var markerWidthConstraint: NSLayoutConstraint? = nil
    private var markerHeightConstraint: NSLayoutConstraint? = nil

    @Invalidating(.constraints)
    private var _color: HSVA = .noop

    public var color: HSVA {
        get { _color }
        set {
            guard _color != newValue else { return }
            _color = newValue
        }
    }

    let panGestureRecognizer = UIPanGestureRecognizer()

    public var continuously: Bool {
        panGestureRecognizer.state == .changed
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(gridColorView)
        gridColorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gridColorView.topAnchor.constraint(equalTo: topAnchor, constant: 1.5),
            gridColorView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 1.5),
            gridColorView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1.5),
            gridColorView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1.5),
        ])

        gridColorView.addSubview(markerView)
        markerView.translatesAutoresizingMaskIntoConstraints = false
        let left = markerView.leftAnchor.constraint(equalTo: gridColorView.leftAnchor, constant: 0)
        let top = markerView.topAnchor.constraint(equalTo: gridColorView.topAnchor, constant: 0)
        let width = markerView.widthAnchor.constraint(equalToConstant: 0)
        let height = markerView.heightAnchor.constraint(equalToConstant: 0)
        NSLayoutConstraint.activate([left, top, width, height])
        markerLeftConstraint = left
        markerTopConstraint = top
        markerWidthConstraint = width
        markerHeightConstraint = height

        panGestureRecognizer.addTarget(self, action: #selector(onPan))
        gridColorView.addGestureRecognizer(panGestureRecognizer)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        gridColorView.addGestureRecognizer(tapGesture)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }

    @objc func onTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        let (x, y) = gridColorView.point(location: location)
        color = gridColorView.color(atX: x, y: y)
        sendActions(for: [.primaryActionTriggered, .valueChanged])
    }

    @objc func onPan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        let (x, y) = gridColorView.point(location: location)
        color = gridColorView.color(atX: x, y: y)
        sendActions(for: [.primaryActionTriggered, .valueChanged])
    }

    public override func setNeedsUpdateConstraints() {
        super.setNeedsUpdateConstraints()

        // move marker
        if let index = gridColorView.index(forColor: color) {
            let (x, y) = gridColorView.point(for: index)
            let to = gridColorView.rect(forX: x, y: y)
            let lineWidth: CGFloat = 3
            let halfLineWidth: CGFloat = lineWidth / 2.0
            let newRect = CGRect(
                x: to.origin.x - halfLineWidth,
                y: to.origin.y - halfLineWidth,
                width: to.size.width + lineWidth,
                height: to.size.height + lineWidth
            )

            markerLeftConstraint?.constant = newRect.origin.x
            markerTopConstraint?.constant = newRect.origin.y
            markerWidthConstraint?.constant = newRect.size.width
            markerHeightConstraint?.constant = newRect.size.height
            markerView.setNeedsDisplay()
            markerView.isHidden = false
        } else {
            markerView.isHidden = true
        }
    }
}

class GridColorMarkerView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        let lineWidth: CGFloat = 3
        let rect = rect.applying(
            CGAffineTransform(
                scaleX: 1.0 - (lineWidth / rect.width),
                y: 1.0 - (lineWidth / rect.height)
            )
            .translatedBy(x: lineWidth / 2.0, y: lineWidth / 2.0)
        )

        let path = UIBezierPath(roundedRect: rect, cornerRadius: 2).cgPath
        context.addPath(path)

        context.setLineWidth(3)
        context.setStrokeColor(UIColor.systemBackground.cgColor)
        context.strokePath()
    }
}

import UIKit

@MainActor
protocol ScopeColorPickerDelegate: AnyObject {
    func scopePickerDidFinishColorPick(_ color: UIColor)
}

@MainActor
protocol ScopeColorPickerDataSource: AnyObject {
    func colors(at location: CGPoint, context: CGContext)
}

final class ScopeColorPickerWindow: UIWindow {
    let reticleView = ReticleView(frame: .null)
    let viewSize: Double = 156
    weak var delegate: ScopeColorPickerDelegate? = nil
    weak var dataSource: ScopeColorPickerDataSource? = nil

    private var reticleCenterXConstraint: NSLayoutConstraint? = nil
    private var reticleCenterYConstraint: NSLayoutConstraint? = nil

    var initialLocation: CGPoint = .zero
    var offset: CGPoint = .zero

    let isContinuePan: Bool
    let continuePanOffsetY: Double = -44
    weak var gestureRecognizer: UIGestureRecognizer? = nil

    init(
        windowScene: UIWindowScene,
        gestureRecognizer: UIGestureRecognizer? = nil
    ) {
        isContinuePan = gestureRecognizer != nil
        super.init(windowScene: windowScene)

        addSubview(reticleView)
        reticleView.translatesAutoresizingMaskIntoConstraints = false
        let cX = reticleView.centerXAnchor.constraint(equalTo: centerXAnchor)
        let cY = reticleView.centerYAnchor.constraint(equalTo: centerYAnchor)
        NSLayoutConstraint.activate([
            cX,
            cY,
            reticleView.widthAnchor.constraint(equalToConstant: viewSize),
            reticleView.heightAnchor.constraint(equalToConstant: viewSize)
        ])
        reticleCenterXConstraint = cX
        reticleCenterYConstraint = cY

        let gestureRecognizer: UIGestureRecognizer = gestureRecognizer ?? UIPanGestureRecognizer()
        gestureRecognizer.addTarget(self, action: #selector(onChangedLocation(_:)))
        if !isContinuePan {
            addGestureRecognizer(gestureRecognizer)
        }
        self.gestureRecognizer = gestureRecognizer

        isHidden = false

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.updateScopeContent(at: self.center)
        }

        if isContinuePan {
            self.initialLocation = gestureRecognizer.location(in: self)

            let offsetX = self.initialLocation.x - self.center.x
            let offsetY = self.initialLocation.y - self.center.y + continuePanOffsetY
            self.offset = CGPoint(x: offsetX, y: offsetY)

            reticleView.isHidden = true

            gestureRecognizer.state = .began
            onChangedLocation(gestureRecognizer)
        }
    }

    public required init?(coder: NSCoder) {
        fatalError()
    }

    public override func makeKey() {
        // workaround: KeyWindowにしたくない
        // https://stackoverflow.com/a/64758605/1131587
    }

    @objc private func onChangedLocation(_ gesture: UIGestureRecognizer) {
        switch gesture.state {
        case .began:
            initialLocation = gesture.location(in: self)
            fallthrough
        case .changed:
            reticleView.isHidden = false
            let translation = translationInView(gesture)
            let translationX = translation.x + offset.x
            let translationY = translation.y + offset.y
            reticleCenterXConstraint?.constant = translationX
            reticleCenterYConstraint?.constant = translationY

        case .ended, .failed, .cancelled:
            reticleView.isHidden = true
            gestureRecognizer?.removeTarget(self, action: #selector(onChangedLocation))
            delegate?.scopePickerDidFinishColorPick(reticleView.color)
        default:
            break
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateScopeContent(at: reticleView.center)
    }

    func updateScopeContent(at location: CGPoint) {
        reticleView.render { context in
            dataSource?.colors(at: location, context: context)
        }
    }

    // UIPanGestureRecognizerとUILongPressGestureRecognizerを受け入れるために自作のtranslationを使う
    private func translationInView(_ gesture: UIGestureRecognizer) -> CGPoint {
        let newLocation = gesture.location(in: self)
        return CGPoint(
            x: newLocation.x - initialLocation.x,
            y: newLocation.y - initialLocation.y
        )
    }
}

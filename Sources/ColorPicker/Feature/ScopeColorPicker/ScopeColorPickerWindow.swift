import UIKit

protocol ScopeColorPickerDelegate: AnyObject {
    func scopePickerDidFinishColorPick(_ color: CGColor)
}

protocol ScopeColorPickerDataSource: AnyObject {
    func colors(at location: CGPoint, context: CGContext)
}

class ScopeColorPickerWindow: UIWindow {
    let reticleView = ReticleView(frame: .null)
    let viewSize: Double = 156
    weak var delegate: ScopeColorPickerDelegate? = nil
    weak var dataSource: ScopeColorPickerDataSource? = nil
    var translationX: Double = 0
    var translationY: Double = 0
    
    let isContinuePan: Bool
    let continuePanOffsetY: Double = -44
    weak var panGestureRecognizer: UIPanGestureRecognizer? = nil
    
    init(
        windowScene: UIWindowScene,
        panGestureRecognizer: UIPanGestureRecognizer? = nil
    ) {
        isContinuePan = panGestureRecognizer != nil
        super.init(windowScene: windowScene)
        
        addSubview(reticleView)
        reticleView.snp.makeConstraints { make in
            make.centerX.equalToSuperview().offset(translationX)
            make.centerY.equalToSuperview().offset(translationY)
            make.size.equalTo(viewSize)
        }
        
        let panGestureRecognizer = panGestureRecognizer ?? UIPanGestureRecognizer()
        panGestureRecognizer.addTarget(self, action: #selector(onPan(_:)))
        if !isContinuePan {
            addGestureRecognizer(panGestureRecognizer)
        }
        self.panGestureRecognizer = panGestureRecognizer
        
        isHidden = false
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.updateScopeContent(at: self.center)
        }
        
        if isContinuePan {
            /// continue pan translation
            let location = panGestureRecognizer.location(in: self)
            let center = self.center
            let x = location.x - center.x
            let y = location.y - center.y
            var initialTranslation = CGPoint(x: x, y: y)
            initialTranslation.y += continuePanOffsetY
            self.translationX = initialTranslation.x
            self.translationY = initialTranslation.y
            panGestureRecognizer.setTranslation(initialTranslation, in: panGestureRecognizer.view)
            reticleView.snp.updateConstraints { make in
                make.centerX.equalToSuperview().offset(translationX)
                make.centerY.equalToSuperview().offset(translationY)
            }
        }
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    public override func makeKey() {
        // workaround: KeyWindowにしたくない
        // https://stackoverflow.com/a/64758605/1131587
    }
    
    @objc private func onPan(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            reticleView.isHidden = false
            fallthrough
        case .changed:
            let translation = gesture.translation(in: gesture.view)
            translationX = translation.x
            translationY = translation.y
            reticleView.snp.updateConstraints { make in
                make.centerX.equalToSuperview().offset(translationX)
                make.centerY.equalToSuperview().offset(translationY)
            }
            
            updateScopeContent(at: reticleView.center)
        case .ended, .failed, .cancelled:
            reticleView.isHidden = true
            panGestureRecognizer?.removeTarget(self, action: #selector(onPan))
            delegate?.scopePickerDidFinishColorPick(reticleView.color)
        default:
            break
        }
    }
    
    func updateScopeContent(at location: CGPoint) {
        reticleView.render { context in
            dataSource?.colors(at: location, context: context)
        }
    }
}

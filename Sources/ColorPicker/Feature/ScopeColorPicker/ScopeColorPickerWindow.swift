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
        reticleView.snp.makeConstraints { make in
            // タップで出した時はpanではなくdragで移動するためtranslationを扱う
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(viewSize)
        }
        
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
            reticleView.isHidden = false
            fallthrough
        case .changed:
            let translation = translationInView(gesture)
            print(translation)
            let translationX = translation.x + offset.x
            let translationY = translation.y + offset.y
            reticleView.snp.updateConstraints { make in
                make.centerX.equalToSuperview().offset(translationX)
                make.centerY.equalToSuperview().offset(translationY)
            }
            
            updateScopeContent(at: reticleView.center)
        case .ended, .failed, .cancelled:
            reticleView.isHidden = true
            gestureRecognizer?.removeTarget(self, action: #selector(onChangedLocation))
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
    
    // UIPanGestureRecognizerとUILongPressGestureRecognizerを受け入れるために自作のtranslationを使う
    private func translationInView(_ gesture: UIGestureRecognizer) -> CGPoint {
        let newLocation = gesture.location(in: self)
        return CGPoint(
            x: newLocation.x - initialLocation.x,
            y: newLocation.y - initialLocation.y
        )
    }
}

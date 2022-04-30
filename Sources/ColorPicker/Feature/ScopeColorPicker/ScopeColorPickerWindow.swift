import UIKit

protocol ScopeColorPickerDelegate: AnyObject {
    func scopePickerDidFinishColorPick(_ color: UIColor)
}

protocol ScopeColorPickerDataSource: AnyObject {
    func colors(at location: CGPoint, context: CGContext)
}

class ScopeColorPickerWindow: UIWindow {
    let reticleView = ReticleView(frame: .null)
    let viewSize: Double = 156
    weak var delegate: ScopeColorPickerDelegate? = nil
    weak var dataSource: ScopeColorPickerDataSource? = nil
    
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        
        addSubview(reticleView)
        reticleView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(viewSize)
        }
        
        let panGesture = UIPanGestureRecognizer()
        panGesture.addTarget(self, action: #selector(onPan(_:)))
        addGestureRecognizer(panGesture)
        
        isHidden = false
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return } 
            self.updateScopeContent(at: self.center)
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
            let location = gesture.location(in: gesture.view)
            reticleView.snp.remakeConstraints { make in
                make.center.equalTo(location)
                make.size.equalTo(viewSize)
            }
            updateScopeContent(at: location)
        case .ended, .failed, .cancelled:
            reticleView.isHidden = true
            delegate?.scopePickerDidFinishColorPick(reticleView.color)
        default:
            break
        }
    }
    
    func updateScopeContent(at location: CGPoint) {
        reticleView.render { [weak self] context in
            self?.dataSource?.colors(at: location, context: context)
        }
    }
}

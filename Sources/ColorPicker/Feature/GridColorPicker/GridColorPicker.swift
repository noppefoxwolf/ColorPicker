import UIKit

class GridColorPicker: UIControl {
    let gridColorView: GridColorView = .init(frame: .null)
    let markerView: GridColorMarkerView = .init(frame: .null)
    
    @Invalidating(.constraints)
    private var _color: UIColor = .white
    
    var color: UIColor {
        get { _color }
        set {
            guard _color != newValue else { return }
            _color = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(gridColorView)
        gridColorView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(1.5)
        }
        
        gridColorView.addSubview(markerView)
        markerView.snp.makeConstraints { make in
            make.left.top.equalTo(0)
            make.size.equalTo(0)
        }
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(onPan))
        gridColorView.addGestureRecognizer(panGesture)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTap))
        gridColorView.addGestureRecognizer(tapGesture)
    }
    
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
    
    override func setNeedsUpdateConstraints() {
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
            
            markerView.snp.updateConstraints { make in
                make.left.equalTo(newRect.origin.x)
                make.top.equalTo(newRect.origin.y)
                make.size.equalTo(newRect.size)
            }
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
        let rect = rect.applying(CGAffineTransform(
            scaleX: 1.0 - (lineWidth / rect.width),
            y: 1.0 - (lineWidth / rect.height)
        ).translatedBy(x: lineWidth / 2.0, y: lineWidth / 2.0))
        
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 2).cgPath
        context.addPath(path)
        
        context.setLineWidth(3)
        context.setStrokeColor(UIColor.systemBackground.cgColor)
        context.strokePath()
    }
}

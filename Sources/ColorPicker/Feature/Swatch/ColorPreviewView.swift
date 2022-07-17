import UIKit

class ColorPreviewView: UIView {
    
    @Invalidating(.display)
    var color: HSVA = .noop
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        self.snp.makeConstraints { make in
            make.size.equalTo(76)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        let path = UIBezierPath(roundedRect: rect, cornerRadius: 10).cgPath
        context.addPath(path)
        context.clip()
        
        context.setFillColor(CGColor(gray: 1, alpha: 1))
        context.fill(rect)
        
        context.setFillColor(CGColor(gray: 0, alpha: 1))
        context.move(to: .zero)
        context.addLine(to: CGPoint(x: rect.width, y: 0))
        context.addLine(to: CGPoint(x: 0, y: rect.height))
        context.fillPath()
        
        context.setFillColor(color.makeColor().cgColor)
        context.fill(rect)
    }
}

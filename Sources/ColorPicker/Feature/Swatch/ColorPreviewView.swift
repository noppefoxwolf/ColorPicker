import UIKit

class ColorPreviewView: UIView {
    
    @Invalidating(.display)
    var color: CGColor = .white
    
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
        context.setFillColor(color)
        context.fill(rect)
    }
}

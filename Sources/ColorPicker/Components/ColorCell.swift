import UIKit

class ColorCell: UICollectionViewCell {
    
    override var isSelected: Bool {
        didSet { setNeedsDisplay() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        if isSelected {
            do { // inner ellipse
                let size = CGSize(width: 17, height: 17)
                context.setFillColor(tintColor.cgColor)
                let origin = CGPoint(
                    x: (rect.width - size.width) / 2,
                    y: (rect.height - size.height) / 2
                )
                context.fillEllipse(in: CGRect(origin: origin, size: size))
            }
            do { // outline
                let size = CGSize(width: 28, height: 28)
                let origin = CGPoint(
                    x: (rect.width - size.width) / 2,
                    y: (rect.height - size.height) / 2
                )
                context.setStrokeColor(tintColor.cgColor)
                context.setLineWidth(3)
                context.strokeEllipse(in: CGRect(origin: origin, size: size))
            }
        } else {
            let size = CGSize(width: 30, height: 30)
            context.setFillColor(tintColor.cgColor)
            let origin = CGPoint(
                x: (rect.width - size.width) / 2,
                y: (rect.height - size.height) / 2
            )
            context.fillEllipse(in: CGRect(origin: origin, size: size))
        }
    }
}

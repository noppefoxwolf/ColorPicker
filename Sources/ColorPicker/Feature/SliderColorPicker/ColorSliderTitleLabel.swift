import UIKit

final class ColorSliderTitleLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        font = UIFontMetrics.default.scaledFont(for: .systemFont(ofSize: 14, weight: .medium))
        adjustsFontForContentSizeCategory = true
        textColor = .secondaryLabel
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

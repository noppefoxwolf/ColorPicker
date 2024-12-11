import UIKit

final class HairlineView: UIVisualEffectView {
    init() {
        let effect = UIVibrancyEffect(
            blurEffect: UIBlurEffect(
                style: .systemChromeMaterial
            ),
            style: .separator
        )
        super.init(effect: effect)
        contentView.backgroundColor = .systemBackground
        self.snp.makeConstraints { make in
            make.height.equalTo(1)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

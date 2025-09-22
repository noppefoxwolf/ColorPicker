import UIKit

class HairlineView: UIVisualEffectView {
    init() {
        let effect = UIVibrancyEffect(
            blurEffect: UIBlurEffect(
                style: .systemChromeMaterial
            ),
            style: .separator
        )
        super.init(effect: effect)
        contentView.backgroundColor = .systemBackground
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 1)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

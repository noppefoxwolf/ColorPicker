import UIKit

class AddColorCell: UICollectionViewCell {
    let backgroundColorView: UIView = .init(frame: .null)
    let imageView: UIImageView = .init(frame: .null)

    override init(frame: CGRect) {
        super.init(frame: frame)

        contentView.addSubview(backgroundColorView)
        backgroundColorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundColorView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            backgroundColorView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            backgroundColorView.widthAnchor.constraint(equalToConstant: 30),
            backgroundColorView.heightAnchor.constraint(equalToConstant: 30),
        ])
        backgroundColorView.backgroundColor = .lightGray
        backgroundColorView.layer.cornerRadius = 15

        backgroundColorView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: backgroundColorView.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: backgroundColorView.centerYAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 16),
            imageView.heightAnchor.constraint(equalToConstant: 16),
        ])
        imageView.image = UIImage(
            systemName: "plus",
            withConfiguration: UIImage.SymbolConfiguration(weight: .bold)
        )
        imageView.tintColor = .systemBackground
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

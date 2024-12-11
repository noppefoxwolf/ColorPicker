import UIKit
import SnapKit

final class AddColorCell: UICollectionViewCell {
    let backgroundColorView: UIView = .init(frame: .null)
    let imageView: UIImageView = .init(frame: .null)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(backgroundColorView)
        backgroundColorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(30)
        }
        backgroundColorView.backgroundColor = .lightGray
        backgroundColorView.layer.cornerRadius = 15
        
        backgroundColorView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(16)
        }
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

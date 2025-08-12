import UIKit

final class ClothingCell: UICollectionViewCell {
    private let iv: UIImageView = {
        let v = UIImageView()
        v.contentMode = .scaleAspectFill
        v.clipsToBounds = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.quaternaryLabel.cgColor
        contentView.backgroundColor = .secondarySystemBackground

        contentView.addSubview(iv)
        NSLayoutConstraint.activate([
            iv.topAnchor.constraint(equalTo: contentView.topAnchor),
            iv.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            iv.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            iv.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(with item: ClothingItem) {
        iv.image = item.image
    }
}


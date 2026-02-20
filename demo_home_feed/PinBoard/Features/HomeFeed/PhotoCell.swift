import UIKit
import Nuke

final class PhotoCell: UICollectionViewCell {
    static let reuseIdentifier = "PhotoCell"

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.backgroundColor = AppColors.surface
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.label
        label.textColor = AppColors.onSurface
        label.numberOfLines = 2
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.caption
        label.textColor = AppColors.onSurfaceSecondary
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let likesLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.caption
        label.textColor = AppColors.onSurfaceSecondary
        label.adjustsFontForContentSizeCategory = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupViews() {
        contentView.backgroundColor = AppColors.surface
        contentView.layer.cornerRadius = 12
        contentView.clipsToBounds = true

        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(authorLabel)
        contentView.addSubview(likesLabel)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 6),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            authorLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            authorLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            authorLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

            likesLabel.topAnchor.constraint(equalTo: authorLabel.bottomAnchor, constant: 2),
            likesLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            likesLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            likesLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])

        // Accessibility: aggregate cell content for VoiceOver
        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    func configure(with viewModel: PhotoCellViewModel) {
        titleLabel.text = viewModel.title
        authorLabel.text = viewModel.authorName
        likesLabel.text = viewModel.likesText

        accessibilityLabel = "\(viewModel.title), by \(viewModel.authorName), \(viewModel.likesText)"

        let request = ImageRequest(url: viewModel.imageURL)
        NukeExtensions.loadImage(with: request, into: imageView) { [weak self] result in
            if case .failure = result {
                self?.imageView.image = UIImage(systemName: "photo")
                self?.imageView.contentMode = .scaleAspectFit
                self?.imageView.tintColor = AppColors.onSurfaceSecondary
            }
        }
    }

    /// Sets the image height constraint based on aspect ratio for the waterfall layout
    func setImageHeight(for width: CGFloat, aspectRatio: CGFloat) {
        let imageHeight = width * aspectRatio
        // Remove any previous height constraint on imageView
        imageView.constraints
            .filter { $0.firstAttribute == .height && $0.firstItem === imageView }
            .forEach { imageView.removeConstraint($0) }
        imageView.heightAnchor.constraint(equalToConstant: imageHeight).isActive = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        NukeExtensions.cancelRequest(for: imageView)
        imageView.image = nil
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = nil
        titleLabel.text = nil
        authorLabel.text = nil
        likesLabel.text = nil
        accessibilityLabel = nil
    }
}

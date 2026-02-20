import UIKit

/// Reusable overlay for empty and error states.
/// Displays a centered icon, title, optional message, and a retry button.
final class StateOverlayView: UIView {

    enum Style {
        case empty(message: String)
        case error(message: String)
    }

    var onRetry: (() -> Void)?

    private let iconView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.tintColor = AppColors.onSurfaceSecondary
        iv.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iv.widthAnchor.constraint(equalToConstant: 56),
            iv.heightAnchor.constraint(equalToConstant: 56)
        ])
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.subheading
        label.textColor = AppColors.onSurface
        label.textAlignment = .center
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.body
        label.textColor = AppColors.onSurfaceSecondary
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private lazy var retryButton: UIButton = {
        var config = UIButton.Configuration.filled()
        config.title = "Retry"
        config.baseBackgroundColor = AppColors.primary
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 24, bottom: 10, trailing: 24)
        let button = UIButton(configuration: config)
        button.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        return button
    }()

    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    init(style: Style) {
        super.init(frame: .zero)
        setupViews()
        apply(style: style)
    }

    required init?(coder: NSCoder) { fatalError() }

    func apply(style: Style) {
        switch style {
        case .empty(let message):
            iconView.image = UIImage(systemName: "photo.on.rectangle.angled")
            titleLabel.text = "No Photos"
            messageLabel.text = message
            retryButton.isHidden = false
        case .error(let message):
            iconView.image = UIImage(systemName: "exclamationmark.triangle")
            titleLabel.text = "Something Went Wrong"
            messageLabel.text = message
            retryButton.isHidden = false
        }
    }

    private func setupViews() {
        backgroundColor = AppColors.background

        stack.addArrangedSubview(iconView)
        stack.addArrangedSubview(titleLabel)
        stack.addArrangedSubview(messageLabel)
        stack.addArrangedSubview(retryButton)
        stack.setCustomSpacing(20, after: messageLabel)

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 32),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -32)
        ])

        isAccessibilityElement = false
        titleLabel.accessibilityTraits = .header
    }

    @objc private func retryTapped() {
        onRetry?()
    }
}

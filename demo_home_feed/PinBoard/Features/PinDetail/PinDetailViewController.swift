import UIKit
import Combine
import Nuke

final class PinDetailViewController: UIViewController {

    // MARK: - Properties

    private let viewModel: PinDetailViewModel
    private var cancellables = Set<AnyCancellable>()

    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()

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
        label.font = AppFonts.heading
        label.textColor = AppColors.onSurface
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let authorLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.subheading
        label.textColor = AppColors.secondary
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let authorAvatarView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.layer.cornerRadius = 18
        iv.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            iv.widthAnchor.constraint(equalToConstant: 36),
            iv.heightAnchor.constraint(equalToConstant: 36)
        ])
        return iv
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.body
        label.textColor = AppColors.onSurface
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let likesLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.caption
        label.textColor = AppColors.onSurfaceSecondary
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.caption
        label.textColor = AppColors.onSurfaceSecondary
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let exifLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.caption
        label.textColor = AppColors.onSurfaceSecondary
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let locationLabel: UILabel = {
        let label = UILabel()
        label.font = AppFonts.caption
        label.textColor = AppColors.onSurfaceSecondary
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        spinner.translatesAutoresizingMaskIntoConstraints = false
        return spinner
    }()

    private lazy var errorOverlay: StateOverlayView = {
        let overlay = StateOverlayView(style: .error(message: ""))
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.isHidden = true
        overlay.onRetry = { [weak self] in self?.viewModel.viewDidLoad() }
        return overlay
    }()

    private var imageHeightConstraint: NSLayoutConstraint?

    // MARK: - Init

    init(viewModel: PinDetailViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        bindViewModel()
        viewModel.viewDidLoad()
    }

    // MARK: - Setup

    private func setupViews() {
        view.backgroundColor = AppColors.background

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        view.addSubview(spinner)
        view.addSubview(errorOverlay)

        // Author row
        let authorRow = UIStackView(arrangedSubviews: [authorAvatarView, authorLabel])
        authorRow.axis = .horizontal
        authorRow.spacing = 10
        authorRow.alignment = .center

        // Metadata row
        let metadataRow = UIStackView(arrangedSubviews: [likesLabel, dateLabel])
        metadataRow.axis = .horizontal
        metadataRow.spacing = 16

        contentStack.axis = .vertical
        contentStack.spacing = 12
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.addArrangedSubview(imageView)
        contentStack.addArrangedSubview(makePadded(titleLabel))
        contentStack.addArrangedSubview(makePadded(authorRow))
        contentStack.addArrangedSubview(makePadded(descriptionLabel))
        contentStack.addArrangedSubview(makePadded(metadataRow))
        contentStack.addArrangedSubview(makePadded(exifLabel))
        contentStack.addArrangedSubview(makePadded(locationLabel))

        scrollView.addSubview(contentStack)

        imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: 300)
        imageHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            imageView.leadingAnchor.constraint(equalTo: contentStack.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentStack.trailingAnchor),

            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            errorOverlay.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            errorOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func makePadded(_ view: UIView) -> UIView {
        let container = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: container.topAnchor),
            view.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16)
        ])
        return container
    }

    // MARK: - Combine Binding

    private func bindViewModel() {
        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                switch state {
                case .loading:
                    self.spinner.startAnimating()
                    self.scrollView.isHidden = true
                    self.errorOverlay.isHidden = true
                case .loaded:
                    self.spinner.stopAnimating()
                    self.scrollView.isHidden = false
                    self.errorOverlay.isHidden = true
                    self.updateUI()
                case .error(let message):
                    self.spinner.stopAnimating()
                    self.scrollView.isHidden = true
                    self.errorOverlay.apply(style: .error(message: message))
                    self.errorOverlay.isHidden = false
                }
            }
            .store(in: &cancellables)
    }

    private func updateUI() {
        titleLabel.text = viewModel.titleText
        authorLabel.text = viewModel.authorName
        descriptionLabel.text = viewModel.descriptionText
        descriptionLabel.isHidden = viewModel.descriptionText.isEmpty
        likesLabel.text = viewModel.likesText
        dateLabel.text = viewModel.dateText
        exifLabel.text = viewModel.exifText
        exifLabel.isHidden = viewModel.exifText.isEmpty
        locationLabel.text = viewModel.locationText
        locationLabel.isHidden = viewModel.locationText.isEmpty

        if let url = viewModel.imageURL {
            NukeExtensions.loadImage(with: url, into: imageView) { [weak self] result in
                switch result {
                case .success(let response):
                    let aspect = response.image.size.height / response.image.size.width
                    let width = self?.view.bounds.width ?? 300
                    self?.imageHeightConstraint?.constant = width * aspect
                case .failure:
                    self?.imageView.image = UIImage(systemName: "photo")
                    self?.imageView.contentMode = .scaleAspectFit
                    self?.imageView.tintColor = AppColors.onSurfaceSecondary
                }
            }
        }

        if let avatarURL = viewModel.authorAvatarURL {
            NukeExtensions.loadImage(with: avatarURL, into: authorAvatarView)
        }
    }
}

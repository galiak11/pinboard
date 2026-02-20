import UIKit
import Combine
import Nuke

final class HomeFeedViewController: UIViewController {

    // MARK: - Properties

    weak var delegate: HomeFeedDelegate?

    private let viewModel: HomeFeedViewModel
    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, String>!
    private let refreshControl = UIRefreshControl()
    private let prefetcher = ImagePrefetcher()
    private var cancellables = Set<AnyCancellable>()

    private lazy var stateOverlay: StateOverlayView = {
        let overlay = StateOverlayView(style: .empty(message: "Pull to refresh"))
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.isHidden = true
        overlay.onRetry = { [weak self] in self?.viewModel.didPullToRefresh() }
        return overlay
    }()

    private enum Section { case main }

    // MARK: - Init

    init(viewModel: HomeFeedViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupDataSource()
        bindViewModel()
        viewModel.viewDidLoad()
    }

    // MARK: - Setup

    private func setupViews() {
        title = "Home"
        view.backgroundColor = AppColors.background

        let layout = WaterfallLayout()
        layout.delegate = self

        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = AppColors.background
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifier)
        collectionView.register(
            LoadingFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: LoadingFooterView.reuseIdentifier
        )

        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl

        view.addSubview(collectionView)
        view.addSubview(stateOverlay)

        NSLayoutConstraint.activate([
            stateOverlay.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stateOverlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stateOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stateOverlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupDataSource() {
        dataSource = UICollectionViewDiffableDataSource(
            collectionView: collectionView
        ) { [weak self] collectionView, indexPath, photoID in
            guard let self,
                  let cell = collectionView.dequeueReusableCell(
                      withReuseIdentifier: PhotoCell.reuseIdentifier,
                      for: indexPath
                  ) as? PhotoCell,
                  indexPath.item < self.viewModel.cellViewModels.count
            else {
                return UICollectionViewCell()
            }

            let cellVM = self.viewModel.cellViewModels[indexPath.item]
            let itemWidth = (collectionView.bounds.width
                - WaterfallLayout.sectionInset * 2
                - WaterfallLayout.interItemSpacing) / CGFloat(WaterfallLayout.columnCount)
            cell.setImageHeight(for: itemWidth, aspectRatio: cellVM.aspectRatio)
            cell.configure(with: cellVM)
            return cell
        }

        dataSource.supplementaryViewProvider = { [weak self] collectionView, kind, indexPath in
            guard kind == UICollectionView.elementKindSectionFooter,
                  let footer = collectionView.dequeueReusableSupplementaryView(
                      ofKind: kind,
                      withReuseIdentifier: LoadingFooterView.reuseIdentifier,
                      for: indexPath
                  ) as? LoadingFooterView
            else {
                return UICollectionReusableView()
            }

            if case .loadingMore = self?.viewModel.state {
                footer.startAnimating()
            } else {
                footer.stopAnimating()
            }
            return footer
        }
    }

    // MARK: - Combine Binding

    private func bindViewModel() {
        viewModel.$cellViewModels
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] cellViewModels in
                guard let self else { return }
                var snapshot = NSDiffableDataSourceSnapshot<Section, String>()
                snapshot.appendSections([.main])
                snapshot.appendItems(cellViewModels.map(\.id), toSection: .main)

                let isRefresh = self.viewModel.state == .loading
                self.dataSource.apply(snapshot, animatingDifferences: !isRefresh)
            }
            .store(in: &cancellables)

        viewModel.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self else { return }
                self.handleStateChange(state)
            }
            .store(in: &cancellables)
    }

    private func handleStateChange(_ state: HomeFeedViewModel.FeedState) {
        switch state {
        case .idle:
            stateOverlay.isHidden = true
        case .loading:
            stateOverlay.isHidden = true
        case .loaded(let hasMore):
            refreshControl.endRefreshing()
            collectionView.collectionViewLayout.invalidateLayout()
            // Show empty state if no photos
            if viewModel.cellViewModels.isEmpty && !hasMore {
                stateOverlay.apply(style: .empty(message: "No photos found. Pull to refresh."))
                stateOverlay.isHidden = false
                collectionView.isHidden = true
            } else {
                stateOverlay.isHidden = true
                collectionView.isHidden = false
            }
        case .loadingMore:
            stateOverlay.isHidden = true
        case .error(let message):
            refreshControl.endRefreshing()
            // If we have photos, keep showing them — only show full-screen error when empty
            if viewModel.cellViewModels.isEmpty {
                stateOverlay.apply(style: .error(message: message))
                stateOverlay.isHidden = false
                collectionView.isHidden = true
            } else {
                stateOverlay.isHidden = true
                collectionView.isHidden = false
                showErrorBanner(message)
            }
        }
    }

    // MARK: - Actions

    @objc private func handleRefresh() {
        viewModel.didPullToRefresh()
    }

    /// Lightweight error banner when we already have content
    private func showErrorBanner(_ message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default) { [weak self] _ in
            self?.viewModel.didPullToRefresh()
        })
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UICollectionViewDelegate

extension HomeFeedViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard indexPath.item < viewModel.cellViewModels.count else { return }
        let photoID = viewModel.cellViewModels[indexPath.item].id
        delegate?.homeFeedDidSelectPhoto(id: photoID)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if indexPath.item >= viewModel.cellViewModels.count - 4 {
            viewModel.loadNextPage()
        }
    }
}

// MARK: - UICollectionViewDataSourcePrefetching

extension HomeFeedViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap { indexPath -> URL? in
            guard indexPath.item < viewModel.cellViewModels.count else { return nil }
            return viewModel.cellViewModels[indexPath.item].imageURL
        }
        prefetcher.startPrefetching(with: urls)
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        let urls = indexPaths.compactMap { indexPath -> URL? in
            guard indexPath.item < viewModel.cellViewModels.count else { return nil }
            return viewModel.cellViewModels[indexPath.item].imageURL
        }
        prefetcher.stopPrefetching(with: urls)
    }
}
// MARK: - WaterfallLayoutDelegate

extension HomeFeedViewController: WaterfallLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, aspectRatioForItemAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.item < viewModel.cellViewModels.count else { return 1.0 }
        return viewModel.cellViewModels[indexPath.item].aspectRatio
    }
}


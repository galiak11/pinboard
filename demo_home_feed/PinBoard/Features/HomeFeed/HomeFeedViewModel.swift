import Foundation
import Combine

final class HomeFeedViewModel {
    // MARK: - State Machine

    enum FeedState: Equatable {
        case idle
        case loading
        case loaded(hasMore: Bool)
        case loadingMore
        case error(String)
    }

    // MARK: - Published Outputs (Combine)

    @Published private(set) var state: FeedState = .idle
    @Published private(set) var cellViewModels: [PhotoCellViewModel] = []

    // MARK: - Private

    private var photos: [UnsplashPhoto] = []
    private var currentPage = 1
    private let perPage = 20
    private let service: HomeFeedServiceProtocol

    init(service: HomeFeedServiceProtocol) {
        self.service = service
    }

    // MARK: - Inputs

    func viewDidLoad() {
        guard state == .idle else { return }
        transitionTo(.loading)
        fetchPage(currentPage)
    }

    func didPullToRefresh() {
        switch state {
        case .loaded, .error:
            photos = []
            cellViewModels = []
            currentPage = 1
            transitionTo(.loading)
            fetchPage(currentPage)
        default:
            return
        }
    }

    func loadNextPage() {
        guard case .loaded(hasMore: true) = state else { return }
        transitionTo(.loadingMore)
        fetchPage(currentPage)
    }

    // MARK: - Private

    private func fetchPage(_ page: Int) {
        Task { [weak self] in
            guard let self else { return }
            do {
                let newPhotos = try await self.service.fetchPhotos(page: page)
                await MainActor.run {
                    self.handleSuccess(newPhotos: newPhotos)
                }
            } catch {
                await MainActor.run {
                    self.transitionTo(.error(error.localizedDescription))
                }
            }
        }
    }

    private func handleSuccess(newPhotos: [UnsplashPhoto]) {
        if state == .loading {
            photos = newPhotos
        } else {
            photos.append(contentsOf: newPhotos)
        }
        currentPage += 1
        cellViewModels = photos.map { PhotoCellViewModel(photo: $0) }
        transitionTo(.loaded(hasMore: newPhotos.count >= perPage))
    }

    private func transitionTo(_ newState: FeedState) {
        state = newState
    }
}

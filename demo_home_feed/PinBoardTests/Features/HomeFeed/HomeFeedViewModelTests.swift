import Testing
import Combine
import Foundation
@testable import PinBoard

@Suite("HomeFeedViewModel")
struct HomeFeedViewModelTests {

    // MARK: - viewDidLoad

    @Test func viewDidLoad_triggersLoading() async throws {
        let mockService = MockHomeFeedService()
        let sut = HomeFeedViewModel(service: mockService)

        var states: [HomeFeedViewModel.FeedState] = []
        let cancellable = sut.$state.sink { states.append($0) }
        defer { cancellable.cancel() }

        sut.viewDidLoad()
        try await Task.sleep(for: .milliseconds(100))

        #expect(states.contains(.loading))
    }

    @Test func viewDidLoad_success_transitionsToLoaded() async throws {
        let mockService = MockHomeFeedService()
        let photos = TestFixtures.makePhotoList(count: 20)
        mockService.stubbedResult = .success(photos)
        let sut = HomeFeedViewModel(service: mockService)

        sut.viewDidLoad()
        try await Task.sleep(for: .milliseconds(200))

        #expect(sut.state == .loaded(hasMore: true))
        #expect(sut.cellViewModels.count == 20)
    }

    @Test func viewDidLoad_emptyResponse_loadsWithNoMore() async throws {
        let mockService = MockHomeFeedService()
        mockService.stubbedResult = .success([])
        let sut = HomeFeedViewModel(service: mockService)

        sut.viewDidLoad()
        try await Task.sleep(for: .milliseconds(200))

        #expect(sut.state == .loaded(hasMore: false))
        #expect(sut.cellViewModels.count == 0)
    }

    @Test func viewDidLoad_failure_transitionsToError() async throws {
        let mockService = MockHomeFeedService()
        mockService.stubbedResult = .failure(APIError.httpError(statusCode: 500))
        let sut = HomeFeedViewModel(service: mockService)

        sut.viewDidLoad()
        try await Task.sleep(for: .milliseconds(200))

        if case .error = sut.state {
            // expected
        } else {
            Issue.record("Expected .error state, got \(sut.state)")
        }
    }

    // MARK: - loadNextPage

    @Test func loadNextPage_whenLoaded_triggersLoadingMore() async throws {
        let mockService = MockHomeFeedService()
        let photos = TestFixtures.makePhotoList(count: 20)
        mockService.stubbedResult = .success(photos)
        let sut = HomeFeedViewModel(service: mockService)

        sut.viewDidLoad()
        try await Task.sleep(for: .milliseconds(200))
        #expect(sut.state == .loaded(hasMore: true))

        var states: [HomeFeedViewModel.FeedState] = []
        let cancellable = sut.$state.sink { states.append($0) }
        defer { cancellable.cancel() }

        sut.loadNextPage()
        try await Task.sleep(for: .milliseconds(50))

        #expect(states.contains(.loadingMore))
    }

    @Test func loadNextPage_whenAlreadyLoading_ignored() async throws {
        let mockService = MockHomeFeedService()
        let sut = HomeFeedViewModel(service: mockService)

        sut.viewDidLoad()
        sut.loadNextPage()

        try await Task.sleep(for: .milliseconds(200))
        #expect(mockService.fetchCalledWithPages.count == 1)
    }

    @Test func loadNextPage_whenNoMore_ignored() async throws {
        let mockService = MockHomeFeedService()
        mockService.stubbedResult = .success([])
        let sut = HomeFeedViewModel(service: mockService)

        sut.viewDidLoad()
        try await Task.sleep(for: .milliseconds(200))
        #expect(sut.state == .loaded(hasMore: false))

        let callCountBefore = mockService.fetchCalledWithPages.count
        sut.loadNextPage()
        try await Task.sleep(for: .milliseconds(100))

        #expect(mockService.fetchCalledWithPages.count == callCountBefore)
    }

    // MARK: - didPullToRefresh

    @Test func didPullToRefresh_resetsAndReloads() async throws {
        let mockService = MockHomeFeedService()
        let photos = TestFixtures.makePhotoList(count: 20)
        mockService.stubbedResult = .success(photos)
        let sut = HomeFeedViewModel(service: mockService)

        sut.viewDidLoad()
        try await Task.sleep(for: .milliseconds(200))
        #expect(sut.cellViewModels.count == 20)

        let refreshPhotos = TestFixtures.makePhotoList(count: 5)
        mockService.stubbedResult = .success(refreshPhotos)

        sut.didPullToRefresh()
        try await Task.sleep(for: .milliseconds(200))

        #expect(sut.cellViewModels.count == 5)
    }

    @Test func didPullToRefresh_duringLoading_ignored() async throws {
        let mockService = MockHomeFeedService()
        let sut = HomeFeedViewModel(service: mockService)

        sut.viewDidLoad()
        sut.didPullToRefresh()

        try await Task.sleep(for: .milliseconds(200))
        #expect(mockService.fetchCalledWithPages.count == 1)
    }

    @Test func didPullToRefresh_fromError_reloads() async throws {
        let mockService = MockHomeFeedService()
        mockService.stubbedResult = .failure(APIError.httpError(statusCode: 500))
        let sut = HomeFeedViewModel(service: mockService)

        sut.viewDidLoad()
        try await Task.sleep(for: .milliseconds(200))

        let photos = TestFixtures.makePhotoList(count: 10)
        mockService.stubbedResult = .success(photos)

        sut.didPullToRefresh()
        try await Task.sleep(for: .milliseconds(200))

        #expect(sut.cellViewModels.count == 10)
    }

    // MARK: - Cell View Models

    @Test func cellViewModels_correctlyFormatted() async throws {
        let mockService = MockHomeFeedService()
        let photo = TestFixtures.makePhoto(likes: 14500)
        mockService.stubbedResult = .success([photo])
        let sut = HomeFeedViewModel(service: mockService)

        sut.viewDidLoad()
        try await Task.sleep(for: .milliseconds(200))

        #expect(sut.cellViewModels.first?.likesText == "14.5K likes")
    }

    @Test func cellViewModels_aspectRatioCalculated() async throws {
        let mockService = MockHomeFeedService()
        let photo = TestFixtures.makePhoto(width: 4000, height: 6000)
        mockService.stubbedResult = .success([photo])
        let sut = HomeFeedViewModel(service: mockService)

        sut.viewDidLoad()
        try await Task.sleep(for: .milliseconds(200))

        let ratio = sut.cellViewModels.first?.aspectRatio ?? 0
        #expect(abs(ratio - 1.5) < 0.01)
    }

    @Test func cellViewModels_nilDescription_fallback() async throws {
        let mockService = MockHomeFeedService()
        let photo = TestFixtures.makePhoto(description: nil, altDescription: "Alt text")
        mockService.stubbedResult = .success([photo])
        let sut = HomeFeedViewModel(service: mockService)

        sut.viewDidLoad()
        try await Task.sleep(for: .milliseconds(200))

        #expect(sut.cellViewModels.first?.title == "Alt text")
    }
}

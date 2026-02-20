import Foundation

protocol HomeFeedServiceProtocol {
    func fetchPhotos(page: Int) async throws -> [UnsplashPhoto]
}

final class HomeFeedService: HomeFeedServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchPhotos(page: Int) async throws -> [UnsplashPhoto] {
        try await apiClient.request(UnsplashEndpoint.photos(page: page))
    }
}

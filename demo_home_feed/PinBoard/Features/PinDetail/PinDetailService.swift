import Foundation

protocol PinDetailServiceProtocol {
    func fetchPhoto(id: String) async throws -> UnsplashPhoto
}

final class PinDetailService: PinDetailServiceProtocol {
    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchPhoto(id: String) async throws -> UnsplashPhoto {
        try await apiClient.request(UnsplashEndpoint.photo(id: id))
    }
}

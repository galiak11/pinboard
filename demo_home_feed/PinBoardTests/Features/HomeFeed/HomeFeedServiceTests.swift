import Testing
import Foundation
@testable import PinBoard

@Suite("HomeFeedService")
struct HomeFeedServiceTests {

    @Test func fetchPhotos_callsCorrectEndpoint() async throws {
        let mockAPIClient = MockAPIClient()
        let sut = HomeFeedService(apiClient: mockAPIClient)
        let photos = TestFixtures.makePhotoList(count: 3)
        mockAPIClient.stubbedResult = .success(photos)

        _ = try await sut.fetchPhotos(page: 2)

        let endpoint = mockAPIClient.lastRequestedEndpoint
        #expect(endpoint?.path == "/photos")
        #expect(endpoint?.method == .get)

        let queryItems = endpoint?.queryItems
        #expect(queryItems?.contains(URLQueryItem(name: "page", value: "2")) == true)
        #expect(queryItems?.contains(URLQueryItem(name: "per_page", value: "20")) == true)
        #expect(queryItems?.contains(URLQueryItem(name: "order_by", value: "popular")) == true)
    }

    @Test func fetchPhotos_decodesResponse() async throws {
        let mockAPIClient = MockAPIClient()
        let sut = HomeFeedService(apiClient: mockAPIClient)
        let photos = TestFixtures.makePhotoList(count: 5)
        mockAPIClient.stubbedResult = .success(photos)

        let result = try await sut.fetchPhotos(page: 1)

        #expect(result.count == 5)
        #expect(result.first?.id == "photo-0")
    }

    @Test func fetchPhotos_propagatesError() async throws {
        let mockAPIClient = MockAPIClient()
        let sut = HomeFeedService(apiClient: mockAPIClient)
        mockAPIClient.stubbedResult = .failure(APIError.httpError(statusCode: 403))

        await #expect(throws: APIError.self) {
            _ = try await sut.fetchPhotos(page: 1)
        }
    }
}

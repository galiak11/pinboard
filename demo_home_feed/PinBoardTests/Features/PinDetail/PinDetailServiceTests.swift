import Testing
import Foundation
@testable import PinBoard

@Suite("PinDetailService")
struct PinDetailServiceTests {

    @Test func fetchPhoto_callsCorrectEndpoint() async throws {
        let mockAPIClient = MockAPIClient()
        let sut = PinDetailService(apiClient: mockAPIClient)
        let photo = TestFixtures.makePhoto(id: "xyz-789")
        mockAPIClient.stubbedResult = .success(photo)

        _ = try await sut.fetchPhoto(id: "xyz-789")

        let endpoint = mockAPIClient.lastRequestedEndpoint
        #expect(endpoint?.path == "/photos/xyz-789")
        #expect(endpoint?.method == .get)
        #expect(endpoint?.queryItems == nil)
    }

    @Test func fetchPhoto_decodesResponse() async throws {
        let mockAPIClient = MockAPIClient()
        let sut = PinDetailService(apiClient: mockAPIClient)
        let photo = TestFixtures.makePhoto(id: "abc-123", description: "Test photo")
        mockAPIClient.stubbedResult = .success(photo)

        let result = try await sut.fetchPhoto(id: "abc-123")

        #expect(result.id == "abc-123")
        #expect(result.description == "Test photo")
    }

    @Test func fetchPhoto_propagatesError() async throws {
        let mockAPIClient = MockAPIClient()
        let sut = PinDetailService(apiClient: mockAPIClient)
        mockAPIClient.stubbedResult = .failure(APIError.networkError(
            NSError(domain: "test", code: -1009)
        ))

        await #expect(throws: APIError.self) {
            _ = try await sut.fetchPhoto(id: "any")
        }
    }
}

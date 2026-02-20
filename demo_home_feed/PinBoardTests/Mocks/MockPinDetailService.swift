import Foundation
@testable import PinBoard

final class MockPinDetailService: PinDetailServiceProtocol {
    var stubbedResult: Result<UnsplashPhoto, Error> = .failure(APIError.unknown)
    private(set) var fetchCalledWithIDs: [String] = []

    func fetchPhoto(id: String) async throws -> UnsplashPhoto {
        fetchCalledWithIDs.append(id)
        switch stubbedResult {
        case .success(let photo):
            return photo
        case .failure(let error):
            throw error
        }
    }
}

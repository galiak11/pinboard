import Foundation
@testable import PinBoard

final class MockHomeFeedService: HomeFeedServiceProtocol {
    var stubbedResult: Result<[UnsplashPhoto], Error> = .success([])
    private(set) var fetchCalledWithPages: [Int] = []

    func fetchPhotos(page: Int) async throws -> [UnsplashPhoto] {
        fetchCalledWithPages.append(page)
        switch stubbedResult {
        case .success(let photos):
            return photos
        case .failure(let error):
            throw error
        }
    }
}

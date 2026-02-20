import Foundation
@testable import PinBoard

final class MockHomeFeedDelegate: HomeFeedDelegate {
    private(set) var selectedPhotoIDs: [String] = []

    func homeFeedDidSelectPhoto(id: String) {
        selectedPhotoIDs.append(id)
    }
}

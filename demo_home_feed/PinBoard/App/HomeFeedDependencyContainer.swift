import Foundation

/// Scoped dependency container for the Home Feed feature.
/// Holds feature-specific services and provides factory methods for child containers.
final class HomeFeedDependencyContainer {
    private let parent: AppDependencyContainer

    var apiClient: APIClientProtocol { parent.apiClient }
    var imageCache: ImageCaching { parent.imageCache }

    lazy var homeFeedService: HomeFeedServiceProtocol = {
        HomeFeedService(apiClient: parent.apiClient)
    }()

    init(parent: AppDependencyContainer) {
        self.parent = parent
    }

    func makePinDetailContainer(photoID: String) -> PinDetailDependencyContainer {
        PinDetailDependencyContainer(parent: parent, photoID: photoID)
    }
}

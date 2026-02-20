import Foundation

/// Scoped dependency container for the Pin Detail feature.
/// Created per-navigation; each detail screen gets its own service instance.
final class PinDetailDependencyContainer {
    private let parent: AppDependencyContainer
    let photoID: String

    var imageCache: ImageCaching { parent.imageCache }

    lazy var pinDetailService: PinDetailServiceProtocol = {
        PinDetailService(apiClient: parent.apiClient)
    }()

    init(parent: AppDependencyContainer, photoID: String) {
        self.parent = parent
        self.photoID = photoID
    }
}

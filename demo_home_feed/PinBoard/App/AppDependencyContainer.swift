import Foundation

/// Root dependency container — composition root for the entire app.
/// Holds shared, app-scoped services. Feature containers are created via factory methods.
final class AppDependencyContainer {
    lazy var apiClient: APIClientProtocol = {
        APIClient(
            baseURL: URL(string: "https://api.unsplash.com")!,
            accessKey: Secrets.unsplashAccessKey
        )
    }()

    lazy var imageCache: ImageCaching = {
        NukeImageCache()
    }()

    // MARK: - Child Container Factories

    func makeHomeFeedContainer() -> HomeFeedDependencyContainer {
        HomeFeedDependencyContainer(parent: self)
    }

    func makePinDetailContainer(photoID: String) -> PinDetailDependencyContainer {
        PinDetailDependencyContainer(parent: self, photoID: photoID)
    }
}

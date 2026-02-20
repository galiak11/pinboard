import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appCoordinator: AppCoordinator!
    private let container = AppDependencyContainer()

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let navigationController = UINavigationController()
        appCoordinator = AppCoordinator(
            window: window,
            navigationController: navigationController,
            container: container
        )
        appCoordinator.start()

        // Handle deep links passed at launch
        if let url = connectionOptions.urlContexts.first?.url,
           let route = AppRoute(url: url) {
            appCoordinator.navigate(to: route)
        }
    }

    // MARK: - Deep Linking

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url,
              let route = AppRoute(url: url) else { return }
        appCoordinator.navigate(to: route)
    }
}

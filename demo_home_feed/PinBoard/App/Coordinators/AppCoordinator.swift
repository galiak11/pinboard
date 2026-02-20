import UIKit

final class AppCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    private let window: UIWindow
    private let container: AppDependencyContainer
    private var mainTabCoordinator: MainTabCoordinator?

    init(window: UIWindow, navigationController: UINavigationController, container: AppDependencyContainer) {
        self.window = window
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        showMainFlow()
    }

    // MARK: - Deep Linking

    func navigate(to route: AppRoute) {
        mainTabCoordinator?.navigate(to: route)
    }

    // MARK: - Private

    private func showMainFlow() {
        let mainTabCoordinator = MainTabCoordinator(
            navigationController: navigationController,
            container: container
        )
        self.mainTabCoordinator = mainTabCoordinator
        addChild(mainTabCoordinator)
        mainTabCoordinator.start()
    }
}

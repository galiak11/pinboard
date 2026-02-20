import UIKit

final class MainTabCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    private let container: AppDependencyContainer
    private let tabBarController = UITabBarController()

    /// Exposed for deep linking through the coordinator hierarchy
    private(set) var homeFeedCoordinator: HomeFeedCoordinator?

    init(navigationController: UINavigationController, container: AppDependencyContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        let homeNav = UINavigationController()
        let homeFeedContainer = container.makeHomeFeedContainer()
        let homeCoordinator = HomeFeedCoordinator(
            navigationController: homeNav,
            container: homeFeedContainer
        )
        self.homeFeedCoordinator = homeCoordinator
        addChild(homeCoordinator)
        homeCoordinator.start()

        let searchNav = UINavigationController()
        let searchPlaceholder = makePlaceholderVC(title: "Search", icon: "magnifyingglass")
        searchNav.viewControllers = [searchPlaceholder]

        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
        searchNav.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 1)

        tabBarController.viewControllers = [homeNav, searchNav]
        tabBarController.tabBar.tintColor = AppColors.primary

        navigationController.setViewControllers([tabBarController], animated: false)
        navigationController.setNavigationBarHidden(true, animated: false)
    }

    // MARK: - Deep Linking

    func navigate(to route: AppRoute) {
        switch route {
        case .home:
            tabBarController.selectedIndex = 0
            homeFeedCoordinator?.navigationController.popToRootViewController(animated: false)
        case .photoDetail(let id):
            tabBarController.selectedIndex = 0
            homeFeedCoordinator?.navigationController.popToRootViewController(animated: false)
            homeFeedCoordinator?.showPhotoDetail(id: id)
        }
    }

    private func makePlaceholderVC(title: String, icon: String) -> UIViewController {
        let vc = UIViewController()
        vc.view.backgroundColor = AppColors.background
        vc.title = title
        let label = UILabel()
        label.text = "Coming soon"
        label.font = AppFonts.body
        label.textColor = AppColors.onSurfaceSecondary
        label.translatesAutoresizingMaskIntoConstraints = false
        vc.view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: vc.view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor)
        ])
        return vc
    }
}

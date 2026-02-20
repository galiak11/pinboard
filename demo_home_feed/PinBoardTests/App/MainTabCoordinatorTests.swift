import Testing
import UIKit
@testable import PinBoard

@Suite("MainTabCoordinator")
@MainActor
struct MainTabCoordinatorTests {

    @Test func start_createsTabBarWithTwoTabs() {
        let navController = UINavigationController()
        let container = AppDependencyContainer()
        let sut = MainTabCoordinator(
            navigationController: navController,
            container: container
        )

        sut.start()

        let tabBarController = navController.viewControllers.first as? UITabBarController
        #expect(tabBarController != nil)
        #expect(tabBarController?.viewControllers?.count == 2)
    }

    @Test func start_createsHomeFeedCoordinator() {
        let navController = UINavigationController()
        let container = AppDependencyContainer()
        let sut = MainTabCoordinator(
            navigationController: navController,
            container: container
        )

        sut.start()

        #expect(sut.childCoordinators.count == 1)
        #expect(sut.childCoordinators.first is HomeFeedCoordinator)
    }

    @Test func start_firstTabIsHome() {
        let navController = UINavigationController()
        let container = AppDependencyContainer()
        let sut = MainTabCoordinator(
            navigationController: navController,
            container: container
        )

        sut.start()

        let tabBarController = navController.viewControllers.first as? UITabBarController
        let homeNav = tabBarController?.viewControllers?.first as? UINavigationController
        #expect(homeNav?.viewControllers.first is HomeFeedViewController)
    }
}

import Testing
import UIKit
@testable import PinBoard

@Suite("AppCoordinator")
@MainActor
struct AppCoordinatorTests {

    @Test func start_setsWindowRootViewController() {
        let window = UIWindow()
        let navController = UINavigationController()
        let container = AppDependencyContainer()
        let sut = AppCoordinator(
            window: window,
            navigationController: navController,
            container: container
        )

        sut.start()

        #expect(window.rootViewController === navController)
    }

    @Test func start_createsMainTabCoordinator() {
        let window = UIWindow()
        let navController = UINavigationController()
        let container = AppDependencyContainer()
        let sut = AppCoordinator(
            window: window,
            navigationController: navController,
            container: container
        )

        sut.start()

        #expect(sut.childCoordinators.count == 1)
        #expect(sut.childCoordinators.first is MainTabCoordinator)
    }
}

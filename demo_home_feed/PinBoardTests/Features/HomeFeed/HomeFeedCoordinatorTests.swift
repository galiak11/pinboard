import Testing
import UIKit
@testable import PinBoard

@Suite("HomeFeedCoordinator")
@MainActor
struct HomeFeedCoordinatorTests {

    @Test func start_pushesHomeFeedVC() {
        let navController = UINavigationController()
        let container = HomeFeedDependencyContainer(parent: AppDependencyContainer())
        let sut = HomeFeedCoordinator(navigationController: navController, container: container)

        sut.start()

        #expect(navController.viewControllers.count == 1)
        #expect(navController.viewControllers.first is HomeFeedViewController)
    }

    @Test func didSelectPhoto_createsPinDetailCoordinator() {
        let navController = UINavigationController()
        let container = HomeFeedDependencyContainer(parent: AppDependencyContainer())
        let sut = HomeFeedCoordinator(navigationController: navController, container: container)

        sut.start()
        sut.homeFeedDidSelectPhoto(id: "test-photo")

        #expect(sut.childCoordinators.count == 1)
        #expect(sut.childCoordinators.first is PinDetailCoordinator)
    }

    @Test func didSelectPhoto_pushesDetailVC() {
        let navController = UINavigationController()
        let container = HomeFeedDependencyContainer(parent: AppDependencyContainer())
        let sut = HomeFeedCoordinator(navigationController: navController, container: container)

        sut.start()
        sut.homeFeedDidSelectPhoto(id: "test-photo")

        #expect(navController.viewControllers.count == 2)
        #expect(navController.viewControllers.last is PinDetailViewController)
    }
}

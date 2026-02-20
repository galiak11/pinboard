import Testing
import UIKit
@testable import PinBoard

@Suite("PinDetailCoordinator")
@MainActor
struct PinDetailCoordinatorTests {

    @Test func start_pushesDetailVC() {
        let navController = UINavigationController()
        let container = PinDetailDependencyContainer(
            parent: AppDependencyContainer(),
            photoID: "test-id"
        )
        let sut = PinDetailCoordinator(
            navigationController: navController,
            container: container
        )
        sut.start()

        #expect(navController.viewControllers.count == 1)
        #expect(navController.viewControllers.first is PinDetailViewController)
    }

    @Test func deinit_callsOnDismiss() {
        let navController = UINavigationController()
        let container = PinDetailDependencyContainer(
            parent: AppDependencyContainer(),
            photoID: "test-id"
        )
        var dismissCalled = false
        var coordinator: PinDetailCoordinator? = PinDetailCoordinator(
            navigationController: navController,
            container: container
        )
        coordinator?.onDismiss = { dismissCalled = true }
        coordinator = nil

        #expect(dismissCalled)
    }
}

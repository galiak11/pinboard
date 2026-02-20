import UIKit

final class HomeFeedCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    private let container: HomeFeedDependencyContainer

    init(navigationController: UINavigationController, container: HomeFeedDependencyContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        let viewModel = HomeFeedViewModel(service: container.homeFeedService)
        let viewController = HomeFeedViewController(viewModel: viewModel)
        viewController.delegate = self
        navigationController.pushViewController(viewController, animated: false)
    }

    /// Public entry point for deep linking and programmatic navigation
    func showPhotoDetail(id: String) {
        let detailContainer = container.makePinDetailContainer(photoID: id)
        let coordinator = PinDetailCoordinator(
            navigationController: navigationController,
            container: detailContainer
        )
        coordinator.onDismiss = { [weak self] in
            self?.removeChild(coordinator)
        }
        addChild(coordinator)
        coordinator.start()
    }
}

// MARK: - HomeFeedDelegate

extension HomeFeedCoordinator: HomeFeedDelegate {
    func homeFeedDidSelectPhoto(id: String) {
        showPhotoDetail(id: id)
    }
}

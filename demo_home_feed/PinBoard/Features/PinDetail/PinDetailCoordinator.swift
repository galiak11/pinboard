import UIKit

final class PinDetailCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    var onDismiss: (() -> Void)?

    private let container: PinDetailDependencyContainer

    init(navigationController: UINavigationController, container: PinDetailDependencyContainer) {
        self.navigationController = navigationController
        self.container = container
    }

    func start() {
        let viewModel = PinDetailViewModel(
            photoID: container.photoID,
            service: container.pinDetailService
        )
        let viewController = PinDetailViewController(viewModel: viewModel)
        viewController.hidesBottomBarWhenPushed = true
        navigationController.pushViewController(viewController, animated: true)
    }

    deinit {
        onDismiss?()
    }
}

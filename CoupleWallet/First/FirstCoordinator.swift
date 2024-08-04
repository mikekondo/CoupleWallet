import SwiftUI

@MainActor final class FirstCoordinator {
    let transitioner: Transitioner
    var tabCoordinator: TabCoordinator?

    init(transitioner: Transitioner) {
        self.transitioner = transitioner
    }

    func start() {
        let vm = FirstViewModelImpl()
        vm.transitionDelegate = self
        let vc = UIHostingController(rootView: FirstScreenView(vm: vm))
        transitioner.push(viewController: vc, animated: true)
    }
}

extension FirstCoordinator: FirstTransitionDelegate {
    @MainActor func transitionToTab() {
        tabCoordinator = .init(transitioner: transitioner)
        tabCoordinator?.start()
    }
}

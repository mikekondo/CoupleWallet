import SwiftUI

@MainActor final class SignInCoordinator {
    let transitioner: Transitioner
    var tabCoordinator: TabCoordinator?

    init(transitioner: Transitioner) {
        self.transitioner = transitioner
    }

    func start() {
        let vm = SignInViewModelImpl()
        vm.transitionDelegate = self
        let vc = UIHostingController(rootView: SignInScreenView(vm: vm))
        transitioner.push(viewController: vc, animated: true)
    }
}

extension SignInCoordinator: SignInTransitionDelegate {
    @MainActor func transitionToTab() {
        tabCoordinator = .init(transitioner: transitioner)
        tabCoordinator?.start()
    }
}

import SwiftUI

@MainActor final class AddPayCoordinator {
    let transitioner: Transitioner

    init(transitioner: Transitioner) {
        self.transitioner = transitioner
    }

    func start() {
        Task { @MainActor in
            let vm = AddPayViewModelImpl()
            vm.transitionDelegate = self
            let vc = UIHostingController(rootView: AddPayScreenView(vm: vm))            
            transitioner.present(viewController: vc, animated: true, completion: nil)
        }
    }
}

extension AddPayCoordinator: AddPayTransitionDelegate {
    func dismiss() {
        Task { @MainActor in
            transitioner.dismissSelf(animated: true, completion: nil)
        }
    }
}



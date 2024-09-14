import SwiftUI

@MainActor final class AddPayCoordinator {
    let transitioner: Transitioner
    let addPayHandler: () async -> Void

    init(transitioner: Transitioner, addPayHandler: @escaping () async -> Void) {
        self.transitioner = transitioner
        self.addPayHandler = addPayHandler
    }

    func start() {
        Task { @MainActor in
            let vm = AddPayViewModelImpl(addPayHandler: addPayHandler)
            vm.transitionDelegate = self
            let vc = UIHostingController(rootView: AddPayScreenView(vm: vm))            
            transitioner.present(viewController: vc, animated: true, completion: nil)
        }
    }
}

extension AddPayCoordinator: AddPayTransitionDelegate {
    func dismiss(completion: (() -> Void)?) {
        Task { @MainActor in
            transitioner.dismissSelf(animated: true, completion: completion)
        }
    }
}



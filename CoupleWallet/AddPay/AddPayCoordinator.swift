import SwiftUI

@MainActor final class AddPayCoordinator {
    let transitioner: Transitioner

    init(transitioner: Transitioner) {
        self.transitioner = transitioner
    }

    func start() {
        Task { @MainActor in
            let vc = UIHostingController(rootView: AddPayScreenView(vm: AddPayViewModelImpl()))
            transitioner.present(viewController: vc, animated: true, completion: nil)
        }
    }
}



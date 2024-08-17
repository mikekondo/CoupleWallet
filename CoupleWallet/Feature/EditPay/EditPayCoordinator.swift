import Foundation
import SwiftUI

final class EditPayCoordinator {
    let transitioner: Transitioner
    let payData: PayData
    let editHandler: () async -> Void

    init(transitioner: Transitioner, payData: PayData, editHandler: @escaping () async -> Void) {
        self.transitioner = transitioner
        self.payData = payData
        self.editHandler = editHandler
    }

    func start() {
        Task { @MainActor in
            let vm = EditPayViewModelImpl(payData: self.payData, editHandler: self.editHandler)
            vm.transitionDelegate = self
            let view = EditPayScreenView(vm: vm)
            let vc = UIHostingController(rootView: view)
            transitioner.present(viewController: vc, animated: true, completion: nil)
        }
    }
}

extension EditPayCoordinator: EditPayTransitionDelegate {
    func dismiss(completion: @escaping () -> Void) {
        Task { @MainActor in
            transitioner.dismissSelf(animated: true, completion: completion)
        }
    }
}


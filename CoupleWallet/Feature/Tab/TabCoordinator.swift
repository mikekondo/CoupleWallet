import SwiftUI
import UIKit

@MainActor final class TabCoordinator {
    let transitioner: Transitioner
    var payCardCoordinator: PayCardCoordinator?
    var payListCoordinator: PayListCoordinator?

    init(transitioner: Transitioner) {
        self.transitioner = transitioner
    }

    // TODO: なんか一旦MainActorにしないと怒られるためMainActorを付与
    func start() {
        Task { @MainActor in
            let vm = TabViewModelImpl()

            /// PayCard Setting
            payCardCoordinator = .init(transitioner: transitioner)
            let payCardVM = PayCardViewModelImpl()
            payCardVM.transitionDelegate = payCardCoordinator

            /// PayList Setting
            payListCoordinator = .init(transitioner: transitioner)
            let payListVM = PayListViewModelImpl()
            payListVM.transitionDelegate = payListCoordinator

            let vc = UIHostingController(
                rootView: TabScreenView(
                    vm: vm,
                    payCardVM: payCardVM,
                    payListVM: payListVM
                )
            )
            transitioner.push(viewController: vc, animated: true)
        }
    }
}


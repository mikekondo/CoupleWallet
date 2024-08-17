import SwiftUI
import UIKit

@MainActor final class TabCoordinator {
    let transitioner: Transitioner
    var payCardCoordinator: PayCardCoordinator?
    var payListCoordinator: PayListCoordinator?
    var settingCoordinator: SettingCoordinator?

    init(transitioner: Transitioner) {
        self.transitioner = transitioner
    }

    func start() {
        Task { @MainActor in
            let vm = TabViewModelImpl()

            /// PayCard
            payCardCoordinator = .init(transitioner: transitioner)
            let payCardVM = PayCardViewModelImpl()
            payCardVM.transitionDelegate = payCardCoordinator

            /// PayList
            payListCoordinator = .init(transitioner: transitioner)
            let payListVM = PayListViewModelImpl()
            payListVM.transitionDelegate = payListCoordinator

            /// Setting
            settingCoordinator = .init(transitioner: transitioner)
            let settingVM = SettingViewModelImpl()

            let vc = UIHostingController(
                rootView: TabScreenView(
                    vm: vm,
                    payCardVM: payCardVM,
                    payListVM: payListVM,
                    settingVM: settingVM
                )
            )
            vc.navigationItem.hidesBackButton = true
            transitioner.push(viewController: vc, animated: true)
        }
    }
}


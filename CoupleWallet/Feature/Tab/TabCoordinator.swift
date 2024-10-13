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

            let vc = TabHostingController(rootView: TabScreenView(vm: vm, payCardVM: payCardVM, payListVM: payListVM, settingVM: settingVM))
            transitioner.push(viewController: vc, animated: true)
        }
    }
}

class TabHostingController<Content: View>: UIHostingController<Content> {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        Task { @MainActor in
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        Task { @MainActor in
            navigationController?.setNavigationBarHidden(true, animated: false)
        }
    }

}

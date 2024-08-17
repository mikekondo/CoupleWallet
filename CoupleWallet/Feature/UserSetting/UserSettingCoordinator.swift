import Foundation
import SwiftUI

@MainActor
final class UserSettingCoordinator {
    var tabCoordinator: TabCoordinator?
    let transitioner: Transitioner

    init(transitioner: Transitioner) {
        self.transitioner = transitioner
    }

    func start() {
        Task { @MainActor in
            let vm = UserSettingViewModelImpl()
            vm.transitionDelegate = self
            let view = UserSettingScreenView(vm: vm)
            transitioner.push(viewController: UIHostingController(rootView: view), animated: true)
        }
    }
}

extension UserSettingCoordinator: UserSettingTransitionDelegate {
    func transitionToTab() {
        Task { @MainActor in
            tabCoordinator = .init(transitioner: transitioner)
            tabCoordinator?.start()
        }
    }
}

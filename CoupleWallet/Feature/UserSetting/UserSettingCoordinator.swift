import Foundation
import SwiftUI

@MainActor
final class UserSettingCoordinator {
    var tabCoordinator: TabCoordinator?
    let transitioner: Transitioner
    let uid: String

    init(
        transitioner: Transitioner,
        uid: String
    ) {
        self.transitioner = transitioner
        self.uid = uid
    }

    func start() {
        Task { @MainActor in
            let vm = UserSettingViewModelImpl(dataStore: UserDefaults.standard, uid: uid)
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

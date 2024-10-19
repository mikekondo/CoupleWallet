import SwiftUI

@MainActor final class SignInCoordinator {
    let transitioner: Transitioner
    var userSettingCoordinator: UserSettingCoordinator?

    init(transitioner: Transitioner) {
        self.transitioner = transitioner
    }

    func start() {
        let vm = SignInViewModelImpl()
        vm.transitionDelegate = self
        let vc = UIHostingController(rootView: SignInScreenView(vm: vm))
        transitioner.push(viewController: vc, animated: false)
    }
}

extension SignInCoordinator: SignInTransitionDelegate {    
    func transitionToUserSetting() {
        userSettingCoordinator = .init(transitioner: transitioner)
        userSettingCoordinator?.start()
    }
}

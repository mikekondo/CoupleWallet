import Foundation

@MainActor class SettingCoordinator {
    let transitioner: any Transitioner
    var signInCoordinator: SignInCoordinator?

    init(transitioner: Transitioner) {
        self.transitioner = transitioner
    }
}

extension SettingCoordinator: SettingTransitionDelegate {
    func transitionToSignIn() {
        signInCoordinator = .init(transitioner: transitioner)
        signInCoordinator?.start()
    }
}

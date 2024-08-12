import SwiftUI
import FirebaseAuth

@MainActor class AppCoordinator {
    let window: UIWindow
    var signInCoordinator: SignInCoordinator?
    var tabCoordinator: TabCoordinator?
    let navigationController: UINavigationController = UINavigationController()

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        self.window.rootViewController = navigationController
        self.window.makeKeyAndVisible()

        if let user = Auth.auth().currentUser {
            transitionToTabView()
        } else {
            transitionToSignIn()
        }
    }

    func transitionToSignIn() {
        Task { @MainActor in
            signInCoordinator = .init(transitioner: navigationController)
            signInCoordinator?.start()
        }
    }

    func transitionToTabView() {
        Task { @MainActor in
            tabCoordinator = .init(transitioner: navigationController)
            tabCoordinator?.start()
        }
    }
}

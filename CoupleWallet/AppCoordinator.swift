import SwiftUI
import FirebaseAuth

@MainActor class AppCoordinator {
    let window: UIWindow
    var signInCoordinator: SignInCoordinator?
    var tabCoordinator: TabCoordinator?
    let navigationController: UINavigationController = UINavigationController()
    let dataStore = UserDefaults.standard

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        self.window.rootViewController = navigationController
        self.window.makeKeyAndVisible()

        // NOTE: 共通コード発行済みの場合、TabViewに遷移させる
        if let _ = dataStore.shareCode {
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

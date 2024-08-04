import SwiftUI

@MainActor class AppCoordinator {
    let window: UIWindow
    var firstCoordinator: FirstCoordinator?
    let navigationController: UINavigationController = UINavigationController()

    init(window: UIWindow) {
        self.window = window
    }

    func start() {
        self.window.rootViewController = navigationController
        self.window.makeKeyAndVisible()
        firstCoordinator = FirstCoordinator(transitioner: navigationController)
        firstCoordinator?.start()
    }
}

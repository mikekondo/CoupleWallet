import SwiftUI

final class FirstCoordinator {
    let transitioner: Transitioner

    init(transitioner: Transitioner) {
        self.transitioner = transitioner
    }

    func start() {
        let vc = UIHostingController(rootView: FirstScreenView())
        transitioner.push(viewController: vc, animated: true)
    }
}

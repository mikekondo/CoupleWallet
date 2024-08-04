import SwiftUI

@MainActor final class TabCoordinator {
    let transitioner: Transitioner

    init(transitioner: Transitioner) {
        self.transitioner = transitioner
    }

    // TODO: なんか一旦MainActorにしないと怒られるためMainActorを付与
    func start() {
        Task { @MainActor in
            let vm = TabViewModelImpl()
            let vc = UIHostingController(rootView: TabScreenView(vm: vm))
            transitioner.push(viewController: vc, animated: true)
        }
    }
}


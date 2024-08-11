import SwiftUI
import UIKit

@MainActor final class TabCoordinator {
    let transitioner: Transitioner

    init(transitioner: Transitioner) {
        self.transitioner = transitioner
    }

    // TODO: なんか一旦MainActorにしないと怒られるためMainActorを付与
    func start() {
        Task { @MainActor in
            let vm = TabViewModelImpl()
            let page1Vm = Page1ViewModelImpl(transitioner: transitioner)
            let vc = UIHostingController(rootView: TabScreenView(vm: vm, page1Vm: page1Vm))
            transitioner.push(viewController: vc, animated: true)
        }
    }
}


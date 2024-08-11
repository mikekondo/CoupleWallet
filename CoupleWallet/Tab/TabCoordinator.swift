import SwiftUI
import UIKit

@MainActor final class TabCoordinator {
    let transitioner: Transitioner
    var page1Coordinator: PayCardCoordinator?

    init(transitioner: Transitioner) {
        self.transitioner = transitioner
    }

    // TODO: なんか一旦MainActorにしないと怒られるためMainActorを付与
    func start() {
        Task { @MainActor in
            let vm = TabViewModelImpl()
            page1Coordinator = .init(transitioner: transitioner)
            let page1Vm = PayCardViewModelImpl()
            page1Vm.transitionDelegate = page1Coordinator
            let vc = UIHostingController(rootView: TabScreenView(vm: vm, page1Vm: page1Vm))
            transitioner.push(viewController: vc, animated: true)
        }
    }
}


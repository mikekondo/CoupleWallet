import Foundation
import SwiftUI

final class EditPayCoordinator {
    let transitioner: Transitioner
    let payData: PayData    

    init(transitioner: Transitioner, payData: PayData) {
        self.transitioner = transitioner
        self.payData = payData
    }

    func start() {
        Task { @MainActor in
            let vm = EditPayViewModelImpl(payData: self.payData)
            let view = EditPayScreenView(vm: vm)
            let vc = UIHostingController(rootView: view)
            transitioner.present(viewController: vc, animated: true, completion: nil)
        }
    }
}

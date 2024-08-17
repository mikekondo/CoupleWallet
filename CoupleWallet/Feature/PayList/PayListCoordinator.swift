import Foundation

@MainActor
final class PayListCoordinator {
    let transitioner: Transitioner
    var editPayCoordinator: EditPayCoordinator?

    init(transitioner: Transitioner) {
        self.transitioner = transitioner
    }
}

extension PayListCoordinator: PayListTransitionDelegate {    
    func transitionToEditPay(payData: PayData, editHandler: @escaping () async -> Void) {
        editPayCoordinator = .init(transitioner: transitioner, payData: payData, editHandler: editHandler)
        editPayCoordinator?.start()
    }
}


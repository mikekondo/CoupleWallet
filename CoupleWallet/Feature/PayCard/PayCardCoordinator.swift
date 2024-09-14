import Foundation

@MainActor
final class PayCardCoordinator {
    let transitioner: Transitioner
    var addPayCoordinator: AddPayCoordinator?
    var editPayCoordinator: EditPayCoordinator?

    init(transitioner: Transitioner) {
        self.transitioner = transitioner
    }
}

extension PayCardCoordinator: PayCardTransitionDelegate {
    func transitionToAdd(addPayHandler: @escaping () async -> Void) {
        addPayCoordinator = .init(transitioner: transitioner, addPayHandler: addPayHandler)
        addPayCoordinator?.start()
    }

    func transitionToEditPay(payData: PayData, editHandler: @escaping () async -> Void) {
        editPayCoordinator = .init(transitioner: transitioner, payData: payData, editHandler: editHandler)
        editPayCoordinator?.start()
    }
}

import Foundation

@MainActor
final class PayCardCoordinator {
    let transitioner: Transitioner
    var addPayCoordinator: AddPayCoordinator?

    init(transitioner: Transitioner) {
        self.transitioner = transitioner
    }
}

extension PayCardCoordinator: PayCardTransitionDelegate {
    func transitionToAdd(addPayHandler: @escaping () async -> Void) {
        addPayCoordinator = .init(transitioner: transitioner, addPayHandler: addPayHandler)
        addPayCoordinator?.start()
    }
}

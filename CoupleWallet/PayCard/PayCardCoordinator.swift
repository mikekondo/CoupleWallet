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
    func transitionToAdd() {
        addPayCoordinator = .init(transitioner: transitioner)
        addPayCoordinator?.start()
    }
}

import Foundation

@MainActor
final class Page1Coordinator {
    let transitioner: Transitioner
    var addPayCoordinator: AddPayCoordinator?

    init(transitioner: Transitioner) {
        self.transitioner = transitioner
    }
}

extension Page1Coordinator: Page1TransitionDelegate {
    func transitionToAdd() {
        addPayCoordinator = .init(transitioner: transitioner)
        addPayCoordinator?.start()
    }
}

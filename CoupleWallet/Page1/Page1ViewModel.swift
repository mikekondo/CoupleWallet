import Foundation

protocol Page1ViewModel: ObservableObject {
    var shouldShowPayView: Bool { get set }
    func didTapCardView()
    func didTapAddButton()
}

final class Page1ViewModelImpl: Page1ViewModel {
    @Published var shouldShowPayView: Bool = true
    let transitioner: Transitioner
    var addPayCoordinator: AddPayCoordinator?

    init(transitioner: Transitioner) {        
        self.transitioner = transitioner
    }

    func didTapCardView() {
        shouldShowPayView.toggle()
    }

    func didTapAddButton() {
        Task { @MainActor in
            addPayCoordinator = .init(transitioner: transitioner)
            addPayCoordinator?.start()
        }
    }
}



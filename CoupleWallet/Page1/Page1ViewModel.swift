import Foundation

protocol Page1ViewModel: ObservableObject {
    var shouldShowPayView: Bool { get set }
    func didTapCardView()
    func didTapAddButton()
}

protocol Page1TransitionDelegate: AnyObject {
    func transitionToAdd()
}

final class Page1ViewModelImpl: Page1ViewModel {
    @Published var shouldShowPayView: Bool = true
    weak var transitionDelegate: Page1TransitionDelegate?

    func didTapCardView() {
        shouldShowPayView.toggle()
    }

    func didTapAddButton() {
        transitionDelegate?.transitionToAdd()        
    }
}



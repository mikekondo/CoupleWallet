import Foundation

protocol PayCardViewModel: ObservableObject {
    var shouldShowPayView: Bool { get set }
    func didTapCardView()
    func didTapAddButton()
}

protocol PayCardTransitionDelegate: AnyObject {
    func transitionToAdd()
}

final class PayCardViewModelImpl: PayCardViewModel {
    @Published var shouldShowPayView: Bool = true
    weak var transitionDelegate: PayCardTransitionDelegate?

    func didTapCardView() {
        shouldShowPayView.toggle()
    }

    func didTapAddButton() {
        transitionDelegate?.transitionToAdd()        
    }
}



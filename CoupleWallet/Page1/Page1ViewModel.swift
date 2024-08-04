import Foundation

protocol Page1ViewModel: ObservableObject {
    var shouldShowPayView: Bool { get set }
    func didTapCardView()
}

final class Page1ViewModelImpl: Page1ViewModel {
    @Published var shouldShowPayView: Bool = true

    func didTapCardView() {
        shouldShowPayView.toggle()
    }
}



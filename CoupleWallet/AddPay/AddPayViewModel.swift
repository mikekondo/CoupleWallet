import Foundation

protocol AddPayViewModel: ObservableObject {
    var payTitle: String { get set }
    var payPrice: String { get set }

    func didTapAdd() async
}

protocol AddPayTransitionDelegate: AnyObject {
    func dismiss()
}

final class AddPayViewModelImpl: AddPayViewModel {
    @Published var payTitle: String = ""
    @Published var payPrice: String = ""
    let firebase = FirebaseManager.shared
    weak var transitionDelegate: AddPayTransitionDelegate?

    func didTapAdd() async {
        let payData: PayData = .init(
            title: payTitle,
            name: "マイク",
            price: Int(payPrice) ?? 0,
            date: Date()
        )
        await firebase.savePay(payData: payData)
        transitionDelegate?.dismiss()
    }
}

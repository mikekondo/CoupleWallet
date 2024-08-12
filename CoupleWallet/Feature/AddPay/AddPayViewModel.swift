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
            id: UUID().uuidString,
            title: payTitle,
            name: "マイク",
            price: Int(payPrice) ?? 0,
            date: Date()
        )
        do {
            try await firebase.savePay(payData: payData)
            transitionDelegate?.dismiss()
        } catch {
            print(error.localizedDescription)
        }
    }
}

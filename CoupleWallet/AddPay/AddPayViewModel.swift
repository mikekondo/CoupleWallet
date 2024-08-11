import Foundation

protocol AddPayViewModel: ObservableObject {
    var payTitle: String { get set }
    var payPrice: String { get set }

    func didTapAdd() async
}

final class AddPayViewModelImpl: AddPayViewModel {
    @Published var payTitle: String = ""
    @Published var payPrice: String = ""
    let fireStore = FirestoreManager.shared

    func didTapAdd() async {
        let payData: PayData = .init(
            title: payTitle,
            name: "マイク",
            price: Int(payPrice) ?? 0,
            date: Date()
        )
        await fireStore.savePay(payData: payData)
    }
}

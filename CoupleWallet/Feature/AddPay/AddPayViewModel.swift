import Foundation

@MainActor protocol AddPayViewModel: ObservableObject {
    var payTitle: String { get set }
    var payPrice: String { get set }
    var shouldShowLoading: Bool { get set }

    func didTapAdd() async    
}

protocol AddPayTransitionDelegate: AnyObject {
    func dismiss()
}

final class AddPayViewModelImpl: AddPayViewModel {
    @Published var payTitle: String = ""
    @Published var payPrice: String = ""
    @Published var shouldShowLoading: Bool = false

    let firebase = FirebaseManager.shared
    let dataStore: DataStorable = UserDefaults.standard
    weak var transitionDelegate: AddPayTransitionDelegate?

    func didTapAdd() async {
        shouldShowLoading = true
        defer { shouldShowLoading = false }
        let payData: PayData = .init(
            id: UUID().uuidString,
            title: payTitle,
            byName: dataStore.userName,
            price: Int(payPrice) ?? 0,
            date: Date()
        )
        do {
            try await firebase.savePay(payData: payData)
            transitionDelegate?.dismiss()
        } catch {
            // TODO: エラーハンドリング
            print(error.localizedDescription)
        }
    }
}

import Foundation

@MainActor protocol AddPayViewModel: ObservableObject {
    var payTitle: String { get set }
    var payPrice: String { get set }
    var shouldShowLoading: Bool { get set }
    var isPayByMe: Bool { get set }
    var partnerName: String { get }
    var myName: String { get }

    func didTapAdd() async
    func didTapMyName()
    func didTapPartnerName()
}

protocol AddPayTransitionDelegate: AnyObject {
    func dismiss(completion: (() -> Void)?)
}

final class AddPayViewModelImpl: AddPayViewModel {
    @Published var payTitle: String = ""
    @Published var payPrice: String = ""
    @Published var shouldShowLoading: Bool = false
    @Published var isPayByMe: Bool = true
    let addPayHandler: () async -> Void

    let firebase = FirebaseManager.shared
    let dataStore: DataStorable = UserDefaults.standard
    weak var transitionDelegate: AddPayTransitionDelegate?

    init(addPayHandler: @escaping () async -> Void) {
        self.addPayHandler = addPayHandler
    }

    func didTapAdd() async {
        shouldShowLoading = true
        defer { shouldShowLoading = false }
        let byName = isPayByMe ? myName : partnerName
        let payData: PayData = .init(
            id: UUID().uuidString,
            title: payTitle,
            byName: byName,
            price: Int(payPrice) ?? 0,
            date: Date()
        )
        do {
            try await firebase.savePay(payData: payData)
            transitionDelegate?.dismiss {
                Task {
                    await self.addPayHandler()
                }
            }
        } catch {
            // TODO: エラーハンドリング
            print(error.localizedDescription)
        }
    }    

    var partnerName: String {
        guard let partnerName = dataStore.partnerName else { return "パートナー" }
        return partnerName
    }

    var myName: String {
        dataStore.userName
    }

    func didTapMyName() {
        isPayByMe = true
    }

    func didTapPartnerName() {
        isPayByMe = false
    }
}

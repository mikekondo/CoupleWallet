import Foundation

@MainActor protocol AddPayViewModel: ObservableObject {
    var payTitle: String { get set }
    var payPrice: String { get set }
    var payDate: Date { get set }
    var shouldShowLoading: Bool { get set }
    var isPayByMe: Bool { get set }
    var alertType: AlertType? { get set }
    var partnerName: String { get }
    var myName: String { get }

    func didTapAdd() async
    func didTapMyName()
    func didTapPartnerName()
    func didTapCloseButton()
}

protocol AddPayTransitionDelegate: AnyObject {
    func dismiss(completion: (() -> Void)?)
}

final class AddPayViewModelImpl: AddPayViewModel {
    @Published var payTitle: String = ""
    @Published var payPrice: String = ""
    @Published var payDate: Date = Date()
    @Published var shouldShowLoading: Bool = false
    @Published var alertType: AlertType?
    @Published var isPayByMe: Bool = true
    let addPayHandler: () async -> Void

    let firebase = FirebaseManager.shared
    let dataStore: DataStorable = UserDefaults.standard
    weak var transitionDelegate: AddPayTransitionDelegate?

    init(addPayHandler: @escaping () async -> Void) {
        self.addPayHandler = addPayHandler
    }

    func didTapAdd() async {
        guard validatePrice() else { return }
        shouldShowLoading = true
        defer { shouldShowLoading = false }
        let byName = isPayByMe ? myName : partnerName
        let payData: PayData = .init(
            id: UUID().uuidString,
            title: payTitle,
            byName: byName,
            price: Int(payPrice) ?? 0,
            date: payDate
        )
        do {
            try firebase.savePay(payData: payData)
            HapticFeedbackManager.shared.play(.impact(.medium))
            NotificationCenter.default.post(name: .addPayNotification, object: nil)
            transitionDelegate?.dismiss {
                Task { @MainActor in
                    await self.addPayHandler()
                }
            }
        } catch {
            // TODO: エラーハンドリング
            print(error.localizedDescription)
        }
    }

    // NOTE: 金額未入力で0円以下の場合はエラー
    private func validatePrice() -> Bool {
        if let price = Int(payPrice), price > 0 {
            return true
        } else {
            alertType = .init(message: "金額を0円以上で入力してください")
            return false
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

    func didTapCloseButton() {
        transitionDelegate?.dismiss(completion: nil)
    }
}

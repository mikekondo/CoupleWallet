import Foundation

@MainActor protocol EditPayViewModel: ObservableObject {
    // view logic
    var payTitle: String { get set }
    var payPrice: String { get set }
    var shouldShowLoading: Bool { get set }
    var isPayByMe: Bool { get set }
    var partnerName: String { get }
    var myName: String { get }

    // tap logic
    func didTapEditButton() async
    func didTapMyName()
    func didTapPartnerName()
}

protocol EditPayTransitionDelegate: AnyObject {
    func dismiss()
}

final class EditPayViewModelImpl: EditPayViewModel {
    @Published var payTitle: String
    @Published var payPrice: String
    @Published var shouldShowLoading: Bool = false
    @Published var isPayByMe: Bool = true

    private let payData: PayData
    private let editHandler: () async -> Void

    let firebaseManager = FirebaseManager.shared
    var dataStore: DataStorable = UserDefaults.standard
    weak var transitionDelegate: EditPayTransitionDelegate?

    init(payData: PayData, editHandler: @escaping () async -> Void) {
        self.payData = payData
        self.editHandler = editHandler
        payTitle = payData.title
        payPrice = String(payData.price)
        setupPayNameButton()
    }

    private func setupPayNameButton() {
        isPayByMe = payData.byName == dataStore.userName
    }
}

// MARK: Tap logic

extension EditPayViewModelImpl {
    func didTapEditButton() async {
        shouldShowLoading = true
        defer { shouldShowLoading = false }
        let payData: PayData = .init(
            id: payData.id,
            title: payTitle,
            byName: payData.byName,
            price: Int(payPrice) ?? 0,
            date: payData.date
        )
        do {
            try await firebaseManager.updatePay(payData: payData)
            Task { @MainActor in
                await editHandler()
            }
            transitionDelegate?.dismiss()
        } catch {
            // TODO: エラーハンドリング
            print(error.localizedDescription)
        }
    }
}

// MARK: View Logic

extension EditPayViewModelImpl {
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

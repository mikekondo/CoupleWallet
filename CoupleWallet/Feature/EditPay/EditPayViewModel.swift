import Foundation

@MainActor protocol EditPayViewModel: ObservableObject {
    var payTitle: String { get set }
    var payPrice: String { get set }
    func didTapEditButton() async
}

protocol EditPayTransitionDelegate: AnyObject {
    func dismiss()
}

final class EditPayViewModelImpl: EditPayViewModel {
    @Published var payTitle: String
    @Published var payPrice: String

    private let payData: PayData
    private let editHandler: () async -> Void

    let firebaseManager = FirebaseManager.shared
    weak var transitionDelegate: EditPayTransitionDelegate?

    init(payData: PayData, editHandler: @escaping () async -> Void) {
        self.payData = payData
        self.editHandler = editHandler
        payTitle = payData.title
        payPrice = String(payData.price)
    }

}

// MARK: Tap logic

extension EditPayViewModelImpl {
    func didTapEditButton() async {
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
            print(error.localizedDescription)
        }
    }
}

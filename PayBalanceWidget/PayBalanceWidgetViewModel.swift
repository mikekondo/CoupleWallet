import Foundation

protocol PayBalanceWidgetViewModel {
    var payBalanceCardViewData: PayBalanceCardViewData? { get }
}

class PayBalanceWidgetViewModelImpl: PayBalanceWidgetViewModel {
    let firebaseManager = FirebaseManager.shared
    @Published var payBalanceType: PayBalanceType = .noData

    private func fetchPayBalanceType() async {
        do {
            payBalanceType = try await firebaseManager.getPayBalanceType()
        } catch {
            // TODO: エラーハンドリング
        }
    }

    var payBalanceCardViewData: PayBalanceCardViewData? {
        if case .overPayment(let payerName, let receiverName, let difference) = payBalanceType {
            let nameText = payerName + "→" + receiverName
            let priceText = PriceFormatter.string(forPrice: difference, sign: .tail)
            return .init(nameText: nameText, priceText: priceText)
        } else {
            return nil
        }
    }
}

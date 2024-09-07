import Foundation
import SwiftUI

@MainActor protocol PayCardViewModel: ObservableObject {
    // ui logic
    var shouldShowPayView: Bool { get set }
    var payBalanceCardViewType: PayBalanceCardViewType { get }
    var payBalanceCardViewData: PayBalanceCardViewData? { get }

    // tap logic
    func didTapUpdatePayBalanceButton() async
    func didTapCardView()
    func didTapAddButton()

    // internal
    func viewDidLoad() async
}

protocol PayCardTransitionDelegate: AnyObject {
    func transitionToAdd()
}

enum PayBalanceCardViewType {
    case content
    case equal
    case noData
}

struct PayBalanceCardViewData {
    let nameText: String
    let priceText: String
}

final class PayCardViewModelImpl: PayCardViewModel {
    @Published var shouldShowPayView: Bool = true
    @Published var payBalanceType: PayBalanceType = .noData
    weak var transitionDelegate: PayCardTransitionDelegate?
    let firebaseManager = FirebaseManager.shared
}

// MARK: internal

extension PayCardViewModelImpl {
    func viewDidLoad() async {
        await fetchPayBalanceType()
    }

    private func fetchPayBalanceType() async {
        do {
            payBalanceType = try await firebaseManager.getPayBalanceType()
        } catch {
            // TODO: エラーハンドリング
        }
    }
}

// MARK: tap logic

extension PayCardViewModelImpl {
    func didTapCardView() {
        shouldShowPayView.toggle()
    }

    func didTapAddButton() {
        transitionDelegate?.transitionToAdd()
    }

    func didTapUpdatePayBalanceButton() async {
        await fetchPayBalanceType()
    }
}

// MARK: ui logic

extension PayCardViewModelImpl {
    var payBalanceCardViewType: PayBalanceCardViewType {
        switch payBalanceType {
        case .overPayment:
            return .content
        case .equal:
            return .equal
        case .noData:
            return .noData
        }
    }

    var payBalanceCardViewData: PayBalanceCardViewData? {
        if case .overPayment(let payerName, let receiverName, let difference) = payBalanceType {
            let nameText = payerName + "→" + receiverName
            let priceText = String(difference) + "円"
            return .init(nameText: nameText, priceText: priceText)
        } else {
            return nil
        }
    }
}



import Foundation
import SwiftUI
import FirebaseAuth

@MainActor protocol PayCardViewModel: ObservableObject {
    // ui logic
    var shouldShowPayView: Bool { get set }
    var payBalanceCardViewType: PayBalanceCardViewType { get }
    var payBalanceCardViewData: PayBalanceCardViewData? { get }
    var payListViewType: PayListViewType { get }
    var payViewDataList: [PayViewData] { get }
    var shouldShowLoading: Bool { get set }
    var shouldShowPartnerLinkageView: Bool { get }
    var alertType: AlertType? { get set }

    // tap logic
    func didTapUpdatePayBalanceButton() async
    func didTapCardView()
    func didTapAddButton()
    func didTapPayCell(id: String)
    func didTapDeleteButton(id: String) async
    func didTapPartnerLinkageButton()

    // internal
    func viewDidLoad() async
    func pullToReflesh() async

    // transitionSheet
    var shouldShowAddSheet: Bool { get set }
}

protocol PayCardTransitionDelegate: AnyObject {
    func transitionToAdd(addPayHandler: @escaping () async -> Void)
    func transitionToEditPay(payData: PayData, editHandler: @escaping () async -> Void)
}

enum PayBalanceCardViewType {
    case content
    case equal
    case noData
}

enum PayListViewType {
    case zeroMatch
    case content
    case error
}

struct PayBalanceCardViewData {
    let nameText: String
    let priceText: String
}

final class PayCardViewModelImpl: PayCardViewModel {
    @Published var shouldShowPayView: Bool = true
    @Published var payBalanceType: PayBalanceType = .noData
    @Published var payListResponseType: PayListResponseType = .noData
    @Published var shouldShowLoading: Bool = false
    @Published var alertType: AlertType?
    @Published var shouldShowAddSheet: Bool = false
    weak var transitionDelegate: PayCardTransitionDelegate?
    let firebaseManager = FirebaseManager.shared
    var dataStore = UserDefaults.standard
}

// MARK: internal

extension PayCardViewModelImpl {
    func viewDidLoad() async {
        shouldShowLoading = true
        await fetch()
        shouldShowLoading = false
    }

    func pullToReflesh() async {
        await fetch()
    }

    private func fetch() async {
        await fetchPayBalanceType()
        await fetchPayList()
    }

    private func fetchPayBalanceType() async {
        do {
            payBalanceType = try await firebaseManager.getPayBalanceType()
        } catch {
            // TODO: エラーハンドリング
        }
    }

    private func fetchPayList() async {
        do {
            let payList = try await firebaseManager.fetchPayList()
            if payList.isEmpty {
                payListResponseType = .noData
            } else {
                payListResponseType = .success(payList)
            }
        } catch {
            payListResponseType = .error
        }
    }
}

// MARK: tap logic

extension PayCardViewModelImpl {
    func didTapCardView() {
        shouldShowPayView.toggle()
    }

    func didTapAddButton() {
        transitionDelegate?.transitionToAdd(addPayHandler: {
            await self.fetch()
        })
    }

    func didTapUpdatePayBalanceButton() async {
        await fetchPayBalanceType()
    }

    func didTapPayCell(id: String) {
        if case .success(let payList) = payListResponseType {
            guard let payData = payList.first(where: { $0.id == id}) else {
                return
            }
            transitionDelegate?.transitionToEditPay(payData: payData)  { [weak self] in
                await self?.fetch()
            }
        }
    }

    func didTapDeleteButton(id: String) async {
        do {
            try await firebaseManager.deletePay(id: id)
            await fetch()
        } catch {
            // TODO: エラーハンドリング
            print(error.localizedDescription)
        }
    }

    func didTapPartnerLinkageButton() {
        alertType = .init(title: "パートナーにアプリをインストールしてもらい共有コードを入力してもらってください", message: displayShareCodeMessageText)
    }

    private var displayShareCodeMessageText: String {
        guard let shareCode = dataStore.shareCode else { return "" }
        return "共有コードは " + shareCode + "です"
    }
}

// MARK: ui logic

extension PayCardViewModelImpl {
    // card view
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
            let nameText = payerName + "が" + receiverName + "に"
            let priceText = PriceFormatter.string(forPrice: difference, sign: .tail) + "払う"
            return .init(nameText: nameText, priceText: priceText)
        } else {
            return nil
        }
    }

    // payList view
    var payViewDataList: [PayViewData] {
        if case .success(let payList) = payListResponseType {
            return payList.map { payData in
                getPayViewData(payData: payData)
            }
        } else {
            return []
        }
    }

    func getPayViewData(payData: PayData) -> PayViewData{
        let title = payData.title == "" ? "未入力" : payData.title
        return .init(
            id: payData.id,
            title: title,
            byName: payData.byName + "が立替え",
            dateText: payData.date.formatted(),
            priceText: PriceFormatter.string(forPrice: payData.price, sign: .tail)
        )
    }

    var payListViewType: PayListViewType {
        switch payListResponseType {
        case .success:
            return .content
        case .error:
            return .error
        case .noData:
            return .zeroMatch
        }
    }

    // NOTE: パートナー連携訴求モジュールの表示条件
    // - 連携済みでないこと
    // - 財布作成者であること
    var shouldShowPartnerLinkageView: Bool {
        !dataStore.isPartnerLink && dataStore.shareCode != nil
    }
}



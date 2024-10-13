import Foundation
import SwiftUI
import FirebaseAuth

@MainActor protocol PayCardViewModel: ObservableObject {
    // ui logic
    var shouldShowPayView: Bool { get set }
    var payBalanceCardViewType: PayBalanceCardViewType { get }
    var payBalanceCardViewData: PayBalanceCardViewData? { get }
    var totalPayCardViewData: TotalPayCardViewData { get }
    var shouldShowLoading: Bool { get set }
    var shouldShowPartnerLinkageView: Bool { get }
    var alertType: AlertType? { get set }

    // tap logic
    func didTapUpdatePayBalanceButton() async
    func didTapCardView()
    func didTapAddButton()
    func didTapDeleteButton(id: String) async
    func didTapPartnerLinkageButton()

    // life cycle
    func viewDidLoad() async

    // internal
    func pullToReflesh() async
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

struct PayBalanceCardViewData {
    let nameText: String
    let priceText: String
}

struct TotalPayCardViewData {
    let priceText: String
    let currentMonthText: String
}

final class PayCardViewModelImpl: PayCardViewModel {
    @Published var shouldShowPayView: Bool = true
    @Published var payBalanceType: PayBalanceType = .noData
    @Published var shouldShowLoading: Bool = false
    @Published var alertType: AlertType?
    @Published var totalPayForCurrentPrice: Int = 0
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
        await fetchTotalPayForCurrentMonth()
    }

    private func fetchTotalPayForCurrentMonth() async {
        do {
            totalPayForCurrentPrice = try await firebaseManager.fetchTotalPayForCurrentMonth()
        } catch {
            // TODO: エラーハンドリング
        }
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
        transitionDelegate?.transitionToAdd(addPayHandler: {
            await self.fetch()
        })
    }

    func didTapUpdatePayBalanceButton() async {
        await fetchPayBalanceType()
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
        // TODO: 立替金額が0円時のUIの工夫をしたい
        switch payBalanceType {
        case .overPayment(let payerName, let receiverName, let difference):
            let nameText = payerName + "が" + receiverName + "に"
            let priceText = PriceFormatter.string(forPrice: difference, sign: .tail)
            return .init(nameText: nameText, priceText: priceText + "払う")
        case .equal:
            return .init(nameText: "立替金額は", priceText: "0円です")
        case .noData:
            return nil
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

    // NOTE: パートナー連携訴求モジュールの表示条件
    // - 連携済みでないこと
    // - 財布作成者であること
    var shouldShowPartnerLinkageView: Bool {
        !dataStore.isPartnerLink && dataStore.shareCode != nil
    }

    var totalPayCardViewData: TotalPayCardViewData {
        // 現在月を取得
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "MMMM"
        let currentMonthText = dateFormatter.string(from: Date())

        return .init(priceText: PriceFormatter.string(forPrice: totalPayForCurrentPrice, sign: .tail), currentMonthText: currentMonthText + "の合計金額")
    }
}



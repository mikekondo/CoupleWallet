import Foundation

@MainActor protocol PayListViewModel: ObservableObject {
    // internal
    func onViewDidLoad() async
    func pullToReflesh() async

    // tap logic
    func didTapDeleteButton(id: String) async
    func didTapPayCell(id: String)

    // ui logic
    var payListResponseType: PayListResponseType { get set }
    var payViewDataList: [PayViewData] { get }
    var payListViewType: PayListViewType { get }
    var shouldShowLoading: Bool { get set }
    var filterDateText: String { get set }
    var recentSixMonthsDateTextList: [String] { get }
    func getFilterDateViewData(date: Date) -> FilterDateViewData
}

enum PayListResponseType {
    case success([PayData])
    case error
    case noData
}

enum PayListViewType {
    case content
    case zeromatch
    case error
}

protocol PayListTransitionDelegate: AnyObject {
    func transitionToEditPay(payData: PayData, editHandler: @escaping () async -> Void)
}

struct PayViewData: Identifiable, Equatable {
    let id: String
    let title: String
    let byName: String
    let dateText: String
    let priceText: String
}

struct FilterDateViewData {
    let dateText: String
}

final class PayListViewModelImpl: PayListViewModel {
    @Published var payListResponseType: PayListResponseType = .noData
    @Published var shouldShowLoading: Bool = false    
    @Published var filterDateText: String = ""
    let firebaseManager = FirebaseManager.shared
    weak var transitionDelegate: PayListTransitionDelegate?
}

// MARK: Internal logic

extension PayListViewModelImpl {
    func onViewDidLoad() async {
        await fetchPayList()
    }

    func pullToReflesh() async {
        await fetchPayList()
    }
    
    private func fetchPayList() async {
        shouldShowLoading = true
        defer { shouldShowLoading = false }
        do {
            let payList = try await firebaseManager.fetchPayList()
            payListResponseType = .success(payList)
        } catch {
            payListResponseType = .error
        }
    }
}
// MARK: Tap logic

extension PayListViewModelImpl {
    func didTapDeleteButton(id: String) async {
        do {
            try await firebaseManager.deletePay(id: id)
            await fetchPayList()
        } catch {
            // TODO: エラーハンドリング
            print(error.localizedDescription)
        }
    }

    func didTapPayCell(id: String) {
        if case .success(let payList) = payListResponseType {
            guard let payData = payList.first(where: { $0.id == id }) else { return }
            transitionDelegate?.transitionToEditPay(payData: payData)  { [weak self] in
                await self?.fetchPayList()
            }
        }
    }
}


// MARK: UI logic

extension PayListViewModelImpl {
    var payViewDataList: [PayViewData] {
        if case .success(let payList) = payListResponseType {
            return payList.map { payData in
                getPayViewData(payData: payData)
            }
        } else {
            return []
        }
    }

    var payListViewType: PayListViewType {
        switch payListResponseType {
        case .success(let payList):
            if payList.isEmpty {
                return .zeromatch
            }
            return .content
        case .error:
            return .error
        case .noData:
            return .zeromatch
        }
    }

    func getPayViewData(payData: PayData) -> PayViewData{
        .init(
            id: payData.id,
            title: payData.title,
            byName: payData.byName + "が立替え",
            dateText: payData.date.formatted(),
            priceText: PriceFormatter.string(forPrice: payData.price, sign: .tail)
        )
    }

    /// 直近6ヶ月の月を算出
    var recentSixMonthsDateTextList: [String] {
        // 現在のカレンダーを取得
        let calendar = Calendar.current

        // 現在の日付を取得
        let currentDate = Date()

        // 直近6ヶ月分のDateを格納する配列
        var lastSixMonths: [String] = []

        // 現在の月から6ヶ月分のDateを逆順に取得
        for i in 0..<6 {
            if let date = calendar.date(byAdding: .month, value: -i, to: currentDate) {
                lastSixMonths.append(getFilterDateViewData(date: date).dateText)
            }
        }
        return lastSixMonths
    }

    func getFilterDateViewData(date: Date) -> FilterDateViewData {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy年MM月"
        return .init(dateText:  dateFormatter.string(from: date))
    }
}

import Foundation
import SwiftUI

@MainActor protocol PayListViewModel: ObservableObject {
    func onViewDidLoad() async
    func pullToReflesh() async

    // tap logic
    func didTapDeleteButton(id: String) async
    func didTapFilterDateButton(index: Int) async
    func didTapPayCell(id: String)

    // ui logic
    var payListResponseType: PayListResponseType { get set }
    var payViewDataList: [PayViewData] { get }
    var payListViewType: PayListViewType { get }
    var shouldShowLoading: Bool { get set }
    var filterDateViewDataList: [FilterDateViewData] { get }
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

struct FilterDateViewData {
    let dateText: String
    let dateTextColor: Color
    let dateTextBackgroundColor: AnyGradient
}

struct PayViewData: Identifiable, Equatable {
    let id: String
    let title: String
    let byName: String
    let dateText: String
    let priceText: String
}

final class PayListViewModelImpl: PayListViewModel {
    @Published var payListResponseType: PayListResponseType = .noData
    @Published var shouldShowLoading: Bool = false    
    @Published var filterDate: Date = Date()
    let firebaseManager = FirebaseManager.shared
    weak var transitionDelegate: PayListTransitionDelegate?
}

// MARK: Internal logic

extension PayListViewModelImpl {
    func onViewDidLoad() async {
        await fetchPayList()
        addPayNotification()
    }

    func pullToReflesh() async {
        await fetchPayList()
    }

    func didTapFilterDateButton(index: Int) async {
        HapticFeedbackManager.shared.play(.impact(.light))
        filterDate = recentSixMonthsDateList[index]
        await fetchPayList()
    }

    private func fetchPayList() async {
        shouldShowLoading = true
        defer { shouldShowLoading = false }
        do {
            let payList = try await firebaseManager.fetchPayList(date: filterDate)
            payListResponseType = .success(payList)
        } catch {
            payListResponseType = .error
        }
    }

    private func addPayNotification() {
        NotificationCenter.default.addObserver(
            forName: .addPayNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.fetchPayList()
            }
        }
    }

    private func editPayNotification() {
        NotificationCenter.default.addObserver(
            forName: .editPayNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.fetchPayList()
            }
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
            return payList.compactMap { payData in
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

    func getPayViewData(payData: PayData) -> PayViewData? {
        guard let id = payData.id else { return nil}
        let title = payData.title.isEmpty ? "未入力" : payData.title
        return .init(
            id: id,
            title: title,
            byName: payData.byName + "が立替え",
            dateText: payData.date.formatted(),
            priceText: PriceFormatter.string(forPrice: payData.price, sign: .tail)
        )
    }

    var filterDateViewDataList: [FilterDateViewData] {
        recentSixMonthsDateList.map {
            let calendar = Calendar.current
            let filterYear = calendar.component(.year, from: filterDate)
            let filterMonth = calendar.component(.month, from: filterDate)
            let listYear = calendar.component(.year, from: $0)
            let listMonth = calendar.component(.month, from: $0)

            let isSameYearAndMonth = filterYear == listYear && filterMonth == listMonth

            let dateText = convertDateToYearMonthString(date: $0)
            let dateTextColor = isSameYearAndMonth ? Color.white : Color.black
            let dateTextBackgroundColor = isSameYearAndMonth ? Color.black.gradient : Color.gray.opacity(0.2).gradient

            return .init(
                dateText: dateText,
                dateTextColor: dateTextColor,
                dateTextBackgroundColor: dateTextBackgroundColor
            )
        }
    }

    private  var recentSixMonthsDateList: [Date] {
        // 現在のカレンダーを取得
        let calendar = Calendar.current

        // 現在の日付を取得
        let currentDate = Date()

        // 直近6ヶ月分のDateを格納する配列
        var recentSixMonthsDateList: [Date] = []

        // 現在の月から6ヶ月分のDateを逆順に取得
        for i in 0..<6 {
            if let date = calendar.date(byAdding: .month, value: -i, to: currentDate) {
                recentSixMonthsDateList.append(date)
            }
        }
        return recentSixMonthsDateList
    }

    private func convertDateToYearMonthString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = "yyyy年MM月"
        return dateFormatter.string(from: date)
    }
}

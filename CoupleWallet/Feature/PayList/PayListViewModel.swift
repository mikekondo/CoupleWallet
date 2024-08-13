import Foundation

protocol PayListViewModel: ObservableObject {
    // internal
    func onViewDidLoad() async
    func pullToReflesh() async

    // tap logic
    func didTapDeleteButton(id: String) async

    // ui logic
    var payListResponseType: PayListResponseType { get set }
    var payViewDataList: [PayViewData] { get }
    var shouldShowLoading: Bool { get set }
}

enum PayListResponseType {
    case success([PayData])
    case error
    case noData
}

struct PayViewData: Identifiable {
    let id: String
    let title: String
    let byName: String
    let dateText: String
    let priceText: String
}

final class PayListViewModelImpl: PayListViewModel {
    @Published var payListResponseType: PayListResponseType = .noData
    @Published var shouldShowLoading: Bool = false
    let firebase = FirebaseManager.shared
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
            let payList = try await firebase.fetchPayList()
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
            try await firebase.deletePay(id: id)
            await fetchPayList()
        } catch {
            print(error.localizedDescription)
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

    func getPayViewData(payData: PayData) -> PayViewData{
        .init(
            id: payData.id,
            title: payData.title,
            byName: payData.name + "が立替え",
            dateText: payData.date.formatted(),
            priceText: String(payData.price) + "円"
        )
    }
}



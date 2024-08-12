import Foundation

protocol PayListViewModel: ObservableObject {
    // internal
    func fetchPayList() async
    func didTapDeleteButton(id: String) async
    // ui logic
    var payListResponseType: PayListResponseType { get set }
    var payViewDataList: [PayViewData] { get }
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
    let firebase = FirebaseManager.shared

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

// MARK: Internal logic

extension PayListViewModelImpl {
    func fetchPayList() async {
        do {
            let payList = try await firebase.fetchPayList()
            payListResponseType = .success(payList)
        } catch {
            payListResponseType = .error
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



import Foundation

protocol PayListViewModel: ObservableObject {
    var payListResponseType: PayListResponseType { get set }
    var payViewDataList: [PayViewData] { get }
    func fetchPayList() async
}

enum PayListResponseType {
    case success([PayData])
    case error
    case noData
}

struct PayViewData: Identifiable {
    let title: String
    let byName: String
    let dateText: String
    let priceText: String
    var id: String {
        UUID().uuidString
    }
}

final class PayListViewModelImpl: PayListViewModel {
    @Published var payListResponseType: PayListResponseType = .noData
    let firebase = FirebaseManager.shared

    func fetchPayList() async {
        do {
            let payList = try await firebase.fetchPayList()
            payListResponseType = .success(payList)
        } catch {
            payListResponseType = .error
        }        
    }

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
            title: payData.title,
            byName: payData.name + "が立替え",
            dateText: payData.date.formatted(),
            priceText: String(payData.price) + "円"
        )
    }
}



import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirebaseManager {
    static let shared = FirebaseManager()
    let dataStore: DataStorable = UserDefaults.standard
    private let db = Firestore.firestore()
    private init() {}
}

// MARK: auth

extension FirebaseManager {
    func saveUser(uid: String, userName: String) async {
        let data: [String: Any] = [
            "name": userName,
            "createdAt": Date()
        ]

        do {
            try await db.collection(.users).document(dataStore.shareCode).setData(data)
        } catch {
            print(error.localizedDescription)
        }
    }
}

// MARK: db logic

extension FirebaseManager {
    func savePay(payData: PayData) async {
        let data: [String: Any] = [
            "title": payData.title,
            "name": payData.name,
            "price": payData.price,
            "createdAt": Date()
        ]

        do {
            try await db.collection(.users).document(dataStore.shareCode).collection(.pay).addDocument(data: data)
        } catch {
            print(error.localizedDescription)
        }
    }

    func fetchPayList() async throws -> [PayData] {
        let querySnapshot = try await db.collection(.users).document(dataStore.shareCode).collection(.pay).getDocuments()
        var payDataList: [PayData] = []

        querySnapshot.documents.forEach { document in
            guard let name = document.get("name") as? String,
                  let price = document.get("price") as? Int,
                  let title = document.get("title") as? String,
                  let date = document.get("createdAt") as? Timestamp else { return }
            payDataList.append(.init(title: title, name: name, price: price, date: date.dateValue()))
        }
        return payDataList
    }
}

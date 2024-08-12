import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirebaseManager {
    static let shared = FirebaseManager()
    let dataStore: DataStorable = UserDefaults.standard
    private let db = Firestore.firestore()
    private init() {}
}

// MARK: db logic

extension FirebaseManager {
    func savePay(payData: PayData) async throws {
        let data: [String: Any] = [
            "id": payData.id,
            "title": payData.title,
            "name": payData.name,
            "price": payData.price,
            "createdAt": Date()
        ]
        try await db.collection(.users).document(dataStore.shareCode).collection(.pay).addDocument(data: data)
    }

    func fetchPayList() async throws -> [PayData] {
        let querySnapshot = try await db.collection(.users).document(dataStore.shareCode).collection(.pay).getDocuments()
        var payDataList: [PayData] = []

        querySnapshot.documents.forEach { document in
            guard let id = document.get("id") as? String,
                  let name = document.get("name") as? String,
                  let price = document.get("price") as? Int,
                  let title = document.get("title") as? String,
                  let date = document.get("createdAt") as? Timestamp else { return }
            payDataList.append(.init(id: id, title: title, name: name, price: price, date: date.dateValue()))
        }
        return payDataList
    }

    func deletePay(id: String) async throws {
        let querySnapshot = try await db.collection("users").document(dataStore.shareCode).collection("pay").whereField("id", isEqualTo: id).getDocuments()

        for document in querySnapshot.documents {
            try await document.reference.delete()
        }
    }
}

import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirebaseManager {
    static let shared = FirebaseManager()
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
            try await db.collection(.users).document(uid).setData(data)
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
        guard let user = Auth.auth().currentUser else { return }

        do {
            try await db.collection(.users).document(user.uid).collection(.pay).addDocument(data: data)
        } catch {
            print(error.localizedDescription)
        }
    }

    func fetchPayList() async throws -> [PayData] {
        guard let user = Auth.auth().currentUser else { return [] }

        let querySnapshot = try await db.collection(.users).document(user.uid).collection(.pay).getDocuments()
        var payDataList: [PayData] = []
        for document in querySnapshot.documents {
            guard let name = document.get("name") as? String,
                  let price = document.get("price") as? Int,
                  let title = document.get("title") as? String,
                  let date = document.get("createdAt") as? Timestamp else { return [] }
            payDataList.append(.init(title: title, name: name, price: price, date: date.dateValue()))
        }
        return payDataList
    }
}

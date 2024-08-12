import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    private init() {}
}

// MARK: auth

extension FirestoreManager {
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

// MARK: logic

extension FirestoreManager {
    func savePay(payData: PayData) async {
        let data: [String: Any] = [
            "title": payData.title,
            "name": payData.name,
            "price": payData.price
        ]
        guard let user = Auth.auth().currentUser else { return }

        do {
            try await db.collection(.users).document(user.uid).collection(.pay).addDocument(data: data)
        } catch {
            print(error.localizedDescription)
        }
    }
}

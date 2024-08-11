import Foundation
import FirebaseFirestore

final class FirestoreManager {
    static let shared = FirestoreManager()
    private let db = Firestore.firestore()
    private init() {}
}

// MARK: logic

extension FirestoreManager {
    func savePay(payData: PayData) async {
        let data: [String: Any] = [
            "title": payData.title,
            "name": payData.name,
            "price": payData.price
        ]

        do {
            try await db.collection(.pay).addDocument(data: data)
        } catch {
            print(error.localizedDescription)
        }
    }
}

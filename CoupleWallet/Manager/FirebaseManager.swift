import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirebaseManager {
    static let shared = FirebaseManager()
    let dataStore: DataStorable = UserDefaults.standard
    private let db = Firestore.firestore()
    private init() {}
}

// MARK: CRUD logic

extension FirebaseManager {
    func saveUser(shareCode: String) async throws {
        let data: [String: Any] = [
            "isPartnerLink": false
        ]
        try await db
            .collection(.users)
            .document(shareCode)
            .setData(data)
    }
    func savePay(payData: PayData) async throws {
        guard let shareCode = dataStore.shareCode else { return }
        let data: [String: Any] = [
            "id": payData.id,
            "title": payData.title,
            "byName": payData.byName,
            "price": payData.price,
            "createdAt": Date()
        ]
        try await db
            .collection(.users)
            .document(shareCode)
            .collection(.pay)
            .document(payData.id)
            .setData(data)
    }

    func updatePay(payData: PayData) async throws {
        guard let shareCode = dataStore.shareCode else { return }
        let data: [String: Any] = [
            "id": payData.id,
            "title": payData.title,
            "byName": payData.byName,
            "price": payData.price,
            "createdAt": Date()
        ]
        try await db
            .collection(.users)
            .document(shareCode)
            .collection(.pay)
            .document(payData.id)
            .updateData(data)
    }

    func fetchPayList() async throws -> [PayData] {
        guard let shareCode = dataStore.shareCode else { return [] }
        let querySnapshot = try await db.collection(.users)
            .document(shareCode)
            .collection(.pay)
            .order(by: "createdAt", descending: true).getDocuments()

        var payDataList: [PayData] = []

        querySnapshot.documents.forEach { document in
            guard let id = document.get("id") as? String,
                  let byName = document.get("byName") as? String,
                  let price = document.get("price") as? Int,
                  let title = document.get("title") as? String,
                  let date = document.get("createdAt") as? Timestamp else { return }
            payDataList.append(.init(id: id, title: title, byName: byName, price: price, date: date.dateValue()))
        }
        return payDataList
    }

    func deletePay(id: String) async throws {
        guard let shareCode = dataStore.shareCode else { return }
        try await db
            .collection("users")
            .document(shareCode)
            .collection("pay")
            .document(id)
            .delete()
    }
}

// MARK: partner link logic

extension FirebaseManager {
    func linkPartner(shareCode: String) async throws {
        let documentRef = db.collection("users").document(shareCode)
        let documentSnapshot = try await documentRef.getDocument(source: .server)

        /// 共通コードがDB上に存在しない時エラーを返す
        guard documentSnapshot.exists else {
            throw LinkPartnerError.noData("共通コード \(shareCode) が存在しないか間違っています")
        }

        let updateData: [String: Any] = [
            "isPartnerLink": true
        ]
        try await documentRef.updateData(updateData)
    }

}

enum LinkPartnerError: Error {
    case noData(String)
    case alreadyLinked(String)
}

// MARK: Account logic

extension FirebaseManager {
    func signIn() async throws {
        _ = try await Auth.auth().signInAnonymously()
    }

    func getAuthUid() -> String? {
        Auth.auth().currentUser?.uid
    }

    func deleteAccount() async throws {
        try await Auth.auth().currentUser?.delete()
        try Auth.auth().signOut()
    }
}

enum SignInError: Error {
    case noData
}

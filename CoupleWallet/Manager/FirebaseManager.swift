import Foundation
import FirebaseFirestore
import FirebaseAuth

final class FirebaseManager {
    static let shared = FirebaseManager()
    var dataStore: DataStorable = UserDefaults.standard
    private let db = Firestore.firestore()
    private init() {}
}

// MARK: CRUD logic

extension FirebaseManager {
    func saveWallet(shareCode: String) async throws {
        let walletRef = db
            .collection(.users)
            .document(shareCode)

        let data: [String: Any] = [
            "isPartnerLink": false,
            "walletOwner": dataStore.userName
        ]

        try await walletRef
            .setData(data, merge: true) // 既存のデータはなさそうだけど、一応mergeフラグをtrueにする

        // パートナー連携されたら、パートナー名をアプリ保存する
        walletRef.addSnapshotListener { [weak self] walletSnapshot, error in
            guard let partnerConnector = walletSnapshot?["partnerConnector"] as? String else { return }
            self?.dataStore.partnerName = partnerConnector
            self?.dataStore.isPartnerLink = true
        }
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
        let payDocuments = try await db
            .collection(.users)
            .document(shareCode)
            .collection(.pay)
            .order(by: "createdAt", descending: true)
            .getDocuments()
            .documents

        var payDataList: [PayData] = []

        payDocuments.forEach { document in
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
            .collection(.users)
            .document(shareCode)
            .collection(.pay)
            .document(id)
            .delete()
    }
}

// MARK: pay balance logic

extension FirebaseManager {
    // 立替計算のロジック
    func getPayBalanceType() async throws -> PayBalanceType {
        guard let shareCode = dataStore.shareCode else { return .noData }

        let payDocuments = try await db
            .collection(.users)
            .document(shareCode)
            .collection(.pay)
            .getDocuments()
            .documents

        // NOTE: 立替の記録がなければ.nodataを返す
        if payDocuments.isEmpty {
            return .noData
        }

        var myTotalPayPrice: Int = 0
        var partnerTotalPayPrice: Int = 0

        payDocuments.forEach { document in
            guard let price = document.get("price") as? Int,
                  let byName = document.get("byName") as? String else { return }
            if byName == dataStore.userName {
                myTotalPayPrice += price
            } else {
                partnerTotalPayPrice += price
            }
        }

        var difference: Int = 0

        if myTotalPayPrice > partnerTotalPayPrice {
            difference = myTotalPayPrice - partnerTotalPayPrice
            return .overPayment(payerName: dataStore.partnerName ?? "パートナー", receiverName: dataStore.userName, difference: difference)
        } else if myTotalPayPrice < partnerTotalPayPrice {
            difference = partnerTotalPayPrice - myTotalPayPrice
            return .overPayment(payerName: dataStore.userName, receiverName: dataStore.partnerName ?? "パートナー", difference: difference)
        } else {
            return .equal
        }
    }
}

// MARK: partner link logic

extension FirebaseManager {
    func linkPartner(shareCode: String) async throws {
        let walletRef = db
            .collection("users")
            .document(shareCode)

        let walletSnapshot = try await walletRef
            .getDocument(source: .server)

        /// 財布DBが存在しない時エラーを返す
        guard walletSnapshot.exists,
        let walletOwner = walletSnapshot.get("walletOwner") as? String else {
            throw LinkPartnerError.noData("共通コード \(shareCode) が存在しないか間違っています")
        }
        dataStore.partnerName = walletOwner

        let data: [String: Any] = [
            "partnerConnector": dataStore.userName,
            "isPartnerLink": true
        ]
        try await walletRef
            .setData(data, merge: true)

        dataStore.isPartnerLink = true
    }
}

enum LinkPartnerError: Error {
    case noData(String)
    case alreadyLinked(String)
    case notCreateWallet(String)
}

// MARK: Account logic

extension FirebaseManager {
    func signIn() async throws {
        _ = try await Auth.auth().signInAnonymously()
        // 非共有キーチェーン設定
        do {
            try Auth.auth().useUserAccessGroup(nil)
        } catch {
            
        }
    }

    func getAuthUid() -> String? {
        Auth.auth().currentUser?.uid
    }

    func deleteAccount() async throws {
        // アカウント削除
        try await Auth.auth().currentUser?.delete()
        // サインアウト
        try Auth.auth().signOut()
        // アプリ内保存全削除
        if let appDomain = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
    }
}

enum SignInError: Error {
    case noData
}

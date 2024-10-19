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
            .setData(data)

        // パートナー連携されたら、パートナー名をアプリ保存する
        walletRef.addSnapshotListener { [weak self] walletSnapshot, error in
            guard let partnerConnector = walletSnapshot?["partnerConnector"] as? String else { return }
            self?.dataStore.partnerName = partnerConnector
            self?.dataStore.isPartnerLink = true
        }
    }

    func savePay(payData: PayData) throws {
        guard let shareCode = dataStore.shareCode else { return }
        try db
            .collection(.users)
            .document(shareCode)
            .collection(.pay)
            .addDocument(from: payData)
    }

    func updatePay(payData: PayData) throws {
        guard let shareCode = dataStore.shareCode else { return }
        guard let id = payData.id else { return }
        try db
            .collection(.users)
            .document(shareCode)
            .collection(.pay)
            .document(id)
            .setData(from: payData)
    }


    func fetchPayList(date: Date) async throws -> [PayData] {
        guard let shareCode = dataStore.shareCode else { return [] }
        // 指定した年と月を取得
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)

        // 現在の月の開始日と終了日を計算
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        guard let startDate = calendar.date(from: components) else { return [] }

        components.month = month + 1
        components.day = 0
        guard let endDate = calendar.date(from: components) else { return [] }

        let payDocuments = try await db
            .collection(.users)
            .document(shareCode)
            .collection(.pay)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startDate))
            .whereField("date", isLessThanOrEqualTo: Timestamp(date: endDate))
            .order(by: "date", descending: true)
            .getDocuments()
            .documents

        let payDataList = payDocuments.compactMap {
            return try? $0.data(as: PayData.self)
        }

        return payDataList
    }

    func fetchTotalPayForCurrentMonth() async throws -> Int {
        guard let shareCode = dataStore.shareCode else { return 0 }
        // 端末の現在の年と月を取得
        let calendar = Calendar.current
        let currentDate = Date()
        let year = calendar.component(.year, from: currentDate)
        let month = calendar.component(.month, from: currentDate)

        // 現在の月の開始日と終了日を計算
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 1
        guard let startDate = calendar.date(from: components) else { return 0 }

        components.month = month + 1
        components.day = 0
        guard let endDate = calendar.date(from: components) else { return 0 }

        let payDocuments = try await db
               .collection(.users)
               .document(shareCode)
               .collection(.pay)
               .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startDate))
               .whereField("date", isLessThanOrEqualTo: Timestamp(date: endDate))
               .getDocuments()
               .documents

        let totalPay = payDocuments.compactMap {
            return try? $0.data(as: PayData.self).price
        }.reduce(0, +)

        return totalPay
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

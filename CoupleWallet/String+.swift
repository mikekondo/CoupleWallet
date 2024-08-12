import Foundation

// MARK: FirestoreのCollectionPath
extension String {
    /// 立替追加
    static var pay: String {
        "pay"
    }

    static var users: String {
        "users"
    }
}

extension String {
    func toInt() -> Int {
        Int(self)!
    }
}

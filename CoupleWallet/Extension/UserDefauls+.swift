import Foundation

extension UserDefaults: DataStorable {
    public enum Key: String, CaseIterable {
        case shareCode
        case userName
    }

    public var shareCode: String {
        get {
            string(forKey: Key.shareCode.rawValue) ?? ""
        }
        set {
            self.set(newValue, forKey: Key.shareCode.rawValue)
        }
    }

    public var userName: String {
        get {
            string(forKey: Key.userName.rawValue) ?? ""
        }
        set {
            self.set(newValue, forKey: Key.userName.rawValue)
        }
    }
}

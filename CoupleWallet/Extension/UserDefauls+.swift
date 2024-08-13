import Foundation

extension UserDefaults: DataStorable {
    public enum Key: String, CaseIterable {
        case shareCode
    }

    public var shareCode: String {
        get {
            string(forKey: Key.shareCode.rawValue) ?? ""
        }
        set {
            self.set(newValue, forKey: Key.shareCode.rawValue)
        }
    }
}

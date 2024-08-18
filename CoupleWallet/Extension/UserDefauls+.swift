import Foundation

extension UserDefaults: DataStorable {
    public enum Key: String, CaseIterable {
        case shareCode
        case userName
        case partnerName
        case isPartnerLink
    }

    public var shareCode: String? {
        get {
            string(forKey: Key.shareCode.rawValue)
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

    public var partnerName: String {
        get {
            string(forKey: Key.partnerName.rawValue) ?? ""
        }
        set {
            self.set(newValue, forKey: Key.partnerName.rawValue)
        }
    }

    public var isPartnerLink: Bool {
        get {
            return self.bool(forKey: Key.isPartnerLink.rawValue)
        }
        set {
            self.set(newValue, forKey: Key.isPartnerLink.rawValue)
        }
    }
}

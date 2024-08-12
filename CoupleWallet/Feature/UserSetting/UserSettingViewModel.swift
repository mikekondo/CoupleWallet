import Foundation
import CryptoKit
import FirebaseAuth

protocol UserSettingViewModel: ObservableObject {
    func didTapCreateWalletButton()
    func didTapLinkParterButton()
}

protocol UserSettingTransitionDelegate: AnyObject {
    func transitionToTab()
}

final class UserSettingViewModelImpl: UserSettingViewModel {
    weak var transitionDelegate: UserSettingTransitionDelegate?
    var dataStore: DataStorable
    let uid: String

    init(
        dataStore: DataStorable,
        uid: String
    ) {
        self.dataStore = dataStore
        self.uid = uid
    }
    
    func didTapCreateWalletButton() {
        dataStore.shareCode = generateShareCodeFromUID()
        transitionDelegate?.transitionToTab()
    }

    func didTapLinkParterButton() {

    }

    func generateShareCodeFromUID() -> String {
        let hash = SHA256.hash(data: Data(self.uid.utf8))
        let hexString = hash.compactMap { String(format: "%02x", $0) }.joined()
        let substring = hexString.prefix(8)
        return String(substring)
    }
}

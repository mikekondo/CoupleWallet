import Foundation
import CryptoKit
import FirebaseAuth

protocol UserSettingViewModel: ObservableObject {
    var shouldShowShareCodeAlert: Bool { get set }
    var shareCode: String { get set }
    func didTapCreateWalletButton()
    func didTapLinkParterButton()
    func didTapAlertOKButton()
    func didTapAlertCancelButton()
}

protocol UserSettingTransitionDelegate: AnyObject {
    func transitionToTab()
}

final class UserSettingViewModelImpl: UserSettingViewModel {
    @Published var shouldShowShareCodeAlert: Bool = false
    @Published var shareCode: String = ""
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
        shouldShowShareCodeAlert = true
    }

    func didTapAlertOKButton() {
        shouldShowShareCodeAlert = false
        dataStore.shareCode = shareCode
        transitionDelegate?.transitionToTab()
    }

    func didTapAlertCancelButton() {
        shouldShowShareCodeAlert = false
    }


    func generateShareCodeFromUID() -> String {
        let hash = SHA256.hash(data: Data(self.uid.utf8))
        let hexString = hash.compactMap { String(format: "%02x", $0) }.joined()
        let substring = hexString.prefix(8)
        return String(substring)
    }
}

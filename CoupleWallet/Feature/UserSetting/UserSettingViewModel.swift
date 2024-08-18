import Foundation
import CryptoKit
import FirebaseAuth

@MainActor protocol UserSettingViewModel: ObservableObject {
    var shouldShowShareCodeAlert: Bool { get set }
    var shareCode: String { get set }
    var shouldShowLoading: Bool { get set }
    var alertType: AlertType? { get set }
    func didTapCreateWalletButton() async
    func didTapLinkParterButton()
    func didTapAlertOKButton() async
    func didTapAlertCancelButton()
}

protocol UserSettingTransitionDelegate: AnyObject {
    func transitionToTab()
}

final class UserSettingViewModelImpl: UserSettingViewModel {
    @Published var shouldShowShareCodeAlert: Bool = false
    @Published var shareCode: String = ""
    @Published var alertType: AlertType?
    @Published var shouldShowLoading: Bool = false

    weak var transitionDelegate: UserSettingTransitionDelegate?
    var dataStore = UserDefaults.standard
    var firebaseManager = FirebaseManager.shared
}

// MARK: Create wallet logic

extension UserSettingViewModelImpl {
    /// 匿名ログイン
    /// uidを発行
    /// 共通コードを発行
    /// 共通コードを使用し、Users配下にDB登録
    /// DB登録に成功したらTabViewに遷移
    func didTapCreateWalletButton() async {
        shouldShowLoading = true
        do {
            // 匿名ログイン
            try await firebaseManager.signIn()
            guard let uid = firebaseManager.getAuthUid() else { return }

            // 共通コード発行
            let shareCode = generateShareCodeFromUID(uid: uid)

            // 財布作成
            try await firebaseManager.saveWallet(shareCode: shareCode)

            dataStore.shareCode = shareCode
            transitionDelegate?.transitionToTab()
        } catch {
            print(error.localizedDescription)
        }
        shouldShowLoading = false
    }

    private func generateShareCodeFromUID(uid: String) -> String {
        let hash = SHA256.hash(data: Data(uid.utf8))
        let hexString = hash.compactMap { String(format: "%02x", $0) }.joined()
        let substring = hexString.prefix(8)
        return String(substring)
    }
}

// MARK: Partner link logic

extension UserSettingViewModelImpl {
    func didTapLinkParterButton() {
        shouldShowShareCodeAlert = true
    }

    /// 匿名ログイン
    /// 共通コードがDB上に存在する時、パートナー連携する
    func didTapAlertOKButton() async {
        shouldShowShareCodeAlert = false
        shouldShowLoading = true
        do {
            try await firebaseManager.signIn()
            try await firebaseManager.linkPartner(shareCode: shareCode)
            dataStore.shareCode = shareCode
            // 連携に成功したら自分の名前をpartnerConnectorとして自分の名前を登録

            transitionDelegate?.transitionToTab()
        } catch let error as LinkPartnerError {
            if case .noData(let message) = error {
                alertType = .init(title: "エラー", message: message)
            }
        } catch {
            // Firebaseのエラーまたは他のエラーの場合の処理
            alertType = .init(title: "エラー", message: "予期しないエラーが発生しました: \(error.localizedDescription)")
        }
        shouldShowLoading = false
    }


    func didTapAlertCancelButton() {
        shouldShowShareCodeAlert = false
    }
}


import Foundation

@MainActor protocol SettingViewModel: ObservableObject {
    var alertType: AlertType? { get set }
    func didTapDeleteAccount() async
    func didTapDisplayShareCode()
    var myName: String { get }
    var partnerName: String { get }
}

final class SettingViewModelImpl: SettingViewModel {
    @Published var alertType: AlertType?
    let firebaseManager = FirebaseManager.shared
    let dataStore = UserDefaults.standard

    func didTapDeleteAccount() async {
        alertType = .init(title: "アカウント削除", message: "アカウントを削除してもよろしいですか？", buttons: [
            .init(title: "キャンセル"),
            .init(title: "OK", action: {
                do {
                    try await self.firebaseManager.deleteAccount()
                } catch {
                    // TODO: エラーハンドリング
                    print(error.localizedDescription)
                }
            })])
    }

    func didTapDisplayShareCode() {
        alertType = .init(title: "パートナーにアプリをインストールしてもらい共有コードを入力してもらってください", message: displayShareCodeMessageText)
    }

    private var displayShareCodeMessageText: String {
        guard let shareCode = dataStore.shareCode else { return "" }
        return "共有コードは " + shareCode + "です"
    }

    var myName: String {
        dataStore.userName
    }

    var partnerName: String {
        guard let partnerName = dataStore.partnerName else { return "パートナーと未連携です" }
        return partnerName
    }
}

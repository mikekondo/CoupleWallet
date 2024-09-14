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
        do {
            try await firebaseManager.deleteAccount()
        } catch {
            // TODO: エラーハンドリング
            print(error.localizedDescription)
        }
    }

    func didTapDisplayShareCode() {
        alertType = .init(title: "共有コードをパートナーに入力してもらってください", message: displayShareCodeMessageText)
    }

    private var displayShareCodeMessageText: String {
        guard let shareCode = dataStore.shareCode else { return "" }
        return "共有コードは " + shareCode + "です"
    }

    var myName: String {
        dataStore.userName
    }

    var partnerName: String {
        dataStore.partnerName
    }
}

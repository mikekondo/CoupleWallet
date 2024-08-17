import Foundation

@MainActor protocol SettingViewModel: ObservableObject {
    func didTapDeleteAccount() async
}

final class SettingViewModelImpl: SettingViewModel {
    let firebaseManager = FirebaseManager.shared

    func didTapDeleteAccount() async {
        do {
            try await firebaseManager.deleteAccount()
        } catch {
            print(error.localizedDescription)
        }
    }
}

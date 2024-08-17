import FirebaseCore
import FirebaseAuth

@MainActor protocol SignInViewModel: ObservableObject {
    var userName: String { get set }
    func registerUserName(userName: String) async
    var alertType: AlertType? { get set }
}

protocol SignInTransitionDelegate: AnyObject {
    func transitionToUserSetting(uid: String)
}

class SignInViewModelImpl: SignInViewModel {
    @Published var userName: String = "マイク"
    @Published var alertType: AlertType?
    var dataStore: DataStorable = UserDefaults.standard
    weak var transitionDelegate: SignInTransitionDelegate?
    let firebase = FirebaseManager.shared

    func registerUserName(userName: String) async {
        do {
            if userName.isEmpty {
                alertType = .init(message: "名前を入力してください")
                return
            }

            let authResult = try await Auth.auth().signInAnonymously()
            let uid = authResult.user.uid
            dataStore.userName = userName

            transitionDelegate?.transitionToUserSetting(uid: uid)
        } catch {
            print(error.localizedDescription)
        }
    }
}

import FirebaseCore
import FirebaseAuth

@MainActor protocol SignInViewModel: ObservableObject {
    var userName: String { get set }
    func registerUserName(userName: String) async
}

protocol SignInTransitionDelegate: AnyObject {
    func transitionToUserSetting(uid: String)
}

class SignInViewModelImpl: SignInViewModel {
    @Published var userName: String = "マイク"
    weak var transitionDelegate: SignInTransitionDelegate?
    let firebase = FirebaseManager.shared

    func registerUserName(userName: String) async {
        do {
            let authResult = try await Auth.auth().signInAnonymously()
            let uid = authResult.user.uid
            transitionDelegate?.transitionToUserSetting(uid: uid)
        } catch {
            print(error.localizedDescription)
        }
    }
}

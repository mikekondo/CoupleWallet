import FirebaseCore
import FirebaseAuth

protocol SignInViewModel: ObservableObject {
    var userName: String { get set }
    func registerUserName(userName: String) async
}

protocol SignInTransitionDelegate: AnyObject {
    func transitionToTab()
}

class SignInViewModelImpl: SignInViewModel {
    @Published var userName: String = "マイク"
    weak var transitionDelegate: SignInTransitionDelegate?
    let firestore = FirestoreManager.shared

    func registerUserName(userName: String) async {
        do {
            let authResult = try await Auth.auth().signInAnonymously()
            let uid = authResult.user.uid
            await firestore.saveUser(uid: uid, userName: userName)
            transitionDelegate?.transitionToTab()
        } catch {
            print(error.localizedDescription)
        }      
    }
}

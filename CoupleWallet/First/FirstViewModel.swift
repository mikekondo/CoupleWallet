import FirebaseCore
import FirebaseAuth

protocol FirstViewModel: ObservableObject {
    func registerUserName(userName: String) async
}

protocol FirstTransitionDelegate: AnyObject {
    func transitionToTab()
}

class FirstViewModelImpl: FirstViewModel {
    weak var transitionDelegate: FirstTransitionDelegate?

    func registerUserName(userName: String) async {
        do {
            try await Auth.auth().signInAnonymously()
        } catch {
            print(error.localizedDescription)
        }

        // TODO: 一旦ここでTabScreenViewに遷移させる
        transitionDelegate?.transitionToTab()
    }
}

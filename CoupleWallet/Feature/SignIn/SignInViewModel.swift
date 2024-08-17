import FirebaseCore
import FirebaseAuth

@MainActor protocol SignInViewModel: ObservableObject {
    var userName: String { get set }
    func registerUserName(userName: String)
    var alertType: AlertType? { get set }
}

protocol SignInTransitionDelegate: AnyObject {
    func transitionToUserSetting()
}

class SignInViewModelImpl: SignInViewModel {
    @Published var userName: String = "マイク"
    @Published var alertType: AlertType?
    var dataStore: DataStorable = UserDefaults.standard
    weak var transitionDelegate: SignInTransitionDelegate?
    let firebase = FirebaseManager.shared

    func registerUserName(userName: String) {
        if userName.isEmpty {
            alertType = .init(title: "名前を入力してください" , message: "名前が空だと登録できません")
            return
        }
        dataStore.userName = userName
        transitionDelegate?.transitionToUserSetting()
    }
}

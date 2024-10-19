import SwiftUI
import AppTrackingTransparency
import GoogleMobileAds

struct SignInScreenView<VM: SignInViewModel>: View {
    @StateObject var vm: VM
    var body: some View {
        VStack(spacing: 24) {
            Text("アカウント登録")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.black)
            VStack(alignment: .leading, spacing: 8) {
                Text("名前")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                TextField("名前を入力してください", text: $vm.userName)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 12)
                    .background(Color(white: 0.95), in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                    )
            }
            Button {
                vm.registerUserName(userName: vm.userName)               
            } label: {
                Text("登録する")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 16)
                    .background(Color.black.gradient, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.horizontal, 16)
        .alert(alertType: $vm.alertType)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                    // ユーザーがトラッキングを許可した場合
                case .authorized:                 
                    GADMobileAds.sharedInstance().start(completionHandler: nil)
                case .denied, .restricted, .notDetermined:
                    GADMobileAds.sharedInstance().start(completionHandler: nil)
                    // オプションで、広告をパーソナライズしない設定を行う
                    GADMobileAds.sharedInstance().requestConfiguration.maxAdContentRating = GADMaxAdContentRating.general
                @unknown default:
                    break
                }
            }
        }
    }
}

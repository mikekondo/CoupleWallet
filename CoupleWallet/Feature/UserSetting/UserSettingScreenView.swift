import SwiftUI

@MainActor struct UserSettingScreenView<VM: UserSettingViewModel>: View {
    @StateObject var vm: VM
    var body: some View {
        VStack(spacing: 32) {
            Text("ユーザー設定")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.black)
            VStack(spacing: 16) {
                Button {
                    Task {
                        await vm.didTapCreateWalletButton()
                    }
                } label: {
                    HStack {
                        Image(systemName: "wallet.pass")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .semibold))
                        Text("新しく財布を作る")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color.black.gradient, in: RoundedRectangle(cornerRadius: 12))
                }
                Button {
                    vm.didTapLinkParterButton()
                } label: {
                    HStack {
                        Image(systemName: "link.circle")
                            .foregroundColor(.black)
                            .font(.system(size: 20, weight: .semibold))
                        Text("パートナーと連携")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.black)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(16)
                    .background(Color(white: 0.95).gradient, in: RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.black.opacity(0.2), lineWidth: 1)
                    )
                }
            }
            AddMobBannerContentView()
                .frame(width: 320, height: 50)
        }
        .padding(.horizontal, 16)
        .alert("パートナーが発行した連携コードを入力", isPresented: $vm.shouldShowShareCodeAlert) {
            TextField("連携コード", text: $vm.shareCode)
            Button {
                vm.didTapAlertCancelButton()
            } label: {
                Text("キャンセル")
            }
            Button {
                Task {
                    await vm.didTapAlertOKButton()
                }
            } label: {
                Text("OK")
            }
        }
        .alert(alertType: $vm.alertType)
        .loading(isPresented: $vm.shouldShowLoading)
        .navigationBarHidden(true)
    }
}

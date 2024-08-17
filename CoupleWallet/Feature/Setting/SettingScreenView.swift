import SwiftUI

struct SettingScreenView<VM: SettingViewModel>: View {
    @StateObject var vm: VM

    var body: some View {
        VStack(spacing: 8) {
            Button {
                Task {
                    await vm.didTapDeleteAccount()
                }
            } label: {
                Text("アカウント削除")
            }
            // TODO: 共有済みの場合は非表示にする
            Button {
                vm.didTapDisplayShareCode()
            } label: {
                Text("共有コード表示")
            }
        }
        .alert(alertType: $vm.alertType)
    }
}

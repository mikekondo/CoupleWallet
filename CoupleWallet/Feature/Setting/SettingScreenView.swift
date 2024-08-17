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
        }
    }
}

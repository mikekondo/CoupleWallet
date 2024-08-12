import SwiftUI

struct UserSettingScreenView<VM: UserSettingViewModel>: View {
    @StateObject var vm: VM
    var body: some View {
        VStack(spacing: 8) {
            Button {
                vm.didTapCreateWalletButton()
            } label: {
                Text("新しく財布を作る")
            }
            Button {
                vm.didTapLinkParterButton()
            } label: {
                Text("パートーナーと連携")
            }
        }
    }
}

#Preview {
    UserSettingScreenView(vm: UserSettingViewModelImpl(dataStore: UserDefaults.standard, uid: "test-uid"))
}

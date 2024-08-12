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
        .alert("パートナーが発行した連携コードを入力", isPresented: $vm.shouldShowShareCodeAlert) {
            TextField("連携コード", text: $vm.shareCode)
            Button {
                vm.didTapAlertCancelButton()
            } label: {
                Text("キャンセル")
            }
            Button {
                vm.didTapAlertOKButton()
            } label: {
                Text("OK")
            }
        }
    }
}

#Preview {
    UserSettingScreenView(vm: UserSettingViewModelImpl(dataStore: UserDefaults.standard, uid: "test-uid"))
}

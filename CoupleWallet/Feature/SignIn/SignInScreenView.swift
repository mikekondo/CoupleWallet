import SwiftUI

struct SignInScreenView<VM: SignInViewModel>: View {
    @StateObject var vm: VM
    var body: some View {
        VStack {
            TextField("名前を入力してください", text: $vm.userName)
                .textFieldStyle(.roundedBorder)
            Button {
                Task { @MainActor in
                    await vm.registerUserName(userName: vm.userName)
                }
            } label: {
                Text("匿名ログインする")
            }
        }
        .padding(.horizontal, 16)
    }
}

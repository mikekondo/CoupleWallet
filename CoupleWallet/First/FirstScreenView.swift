import SwiftUI

struct FirstScreenView<VM: FirstViewModel>: View {
    @StateObject var vm: VM
    var body: some View {
        VStack {
            Button {
                Task { @MainActor in
                    await vm.registerUserName(userName: "hogehoge")
                }
            } label: {
                Text("匿名ログインする")
            }

        }
    }
}

#Preview {
    FirstScreenView(vm: FirstViewModelImpl())
}

import SwiftUI

@MainActor struct TabScreenView<
    VM: TabViewModel,
    PayCardVM: PayCardViewModel,
    PayListVM: PayListViewModel
>: View {
    @StateObject var vm: VM
    @ObservedObject var payCardVM: PayCardVM
    @ObservedObject var payListVM: PayListVM

    var body: some View {
        TabView(selection: $vm.selection) {
            PayCardScreenView(vm: payCardVM)
                .tabItem { Label("立替え", systemImage: "1.circle") }
                .tag(1)
            PayListScreenView(vm: payListVM)
                .tabItem { Label("立替リスト", systemImage: "2.circle") }
                .tag(2)
            SettingScreenView()
                .tabItem { Label("設定", systemImage: "3.circle") }
                .tag(3)
        }
        .navigationBarBackButtonHidden()
    }
}

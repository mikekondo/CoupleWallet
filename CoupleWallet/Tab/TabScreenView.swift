import SwiftUI

@MainActor struct TabScreenView<VM: TabViewModel, Page1VM: PayCardViewModel>: View {
    @StateObject var vm: VM
    @ObservedObject var page1Vm: Page1VM

    var body: some View {
        TabView(selection: $vm.selection) {
            PayCardScreenView(vm: page1Vm)
                .tabItem { Label("立替え", systemImage: "1.circle") }
                .tag(1)
            PayListScreenView()
                .tabItem { Label("立替リスト", systemImage: "2.circle") }
                .tag(2)
            SettingScreenView()
                .tabItem { Label("設定", systemImage: "3.circle") }
                .tag(3)
        }
        .navigationBarBackButtonHidden()
    }
}

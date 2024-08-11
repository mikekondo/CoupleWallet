import SwiftUI

@MainActor struct TabScreenView<VM: TabViewModel, Page1VM: Page1ViewModel>: View {
    @StateObject var vm: VM
    @ObservedObject var page1Vm: Page1VM

    var body: some View {
        TabView(selection: $vm.selection) {
            Page1ScreenView(vm: page1Vm)
                .tabItem { Label("立替え", systemImage: "1.circle") }
                .tag(1)
            Page2ScreenView()
                .tabItem { Label("立替リスト", systemImage: "2.circle") }
                .tag(2)
            Page3ScreenView()
                .tabItem { Label("設定", systemImage: "3.circle") }
                .tag(3)
        }
        .navigationBarBackButtonHidden()
    }
}

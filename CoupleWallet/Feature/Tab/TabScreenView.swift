import SwiftUI

@MainActor struct TabScreenView<
    VM: TabViewModel,
    PayCardVM: PayCardViewModel,
    PayListVM: PayListViewModel,
    SettingVM: SettingViewModel
>: View {
    @StateObject var vm: VM
    @ObservedObject var payCardVM: PayCardVM
    @ObservedObject var payListVM: PayListVM
    @ObservedObject var settingVM: SettingVM

    var body: some View {
        TabView(selection: $vm.selection) {
            PayCardScreenView(vm: payCardVM)
                .tag(TabType.home)
                .toolbar(.hidden, for: .tabBar)
            PayListScreenView(vm: payListVM)
                .tag(TabType.search)
                .toolbar(.hidden, for: .tabBar)
            SettingScreenView(vm: settingVM)
                .tag(TabType.settings)
                .toolbar(.hidden, for: .tabBar)
        }
        .navigationBarBackButtonHidden()
        .padding(.bottom, 36) // カスタムタブバーの高さで調整している
        .overlay(alignment: .bottom) {
            CustomTabBar(tabType: $vm.selection)
        }
    }
}

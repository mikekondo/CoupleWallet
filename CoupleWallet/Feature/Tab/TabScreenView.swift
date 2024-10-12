import SwiftUI

@MainActor struct TabScreenView<
    VM: TabViewModel,
    PayCardVM: PayCardViewModel,
    PayListVM: PayListViewModel,
    SettingVM: SettingViewModel
>: View {
    @StateObject var vm: VM
    @State private var isTabBarHidden: Bool = false
    @ObservedObject var payCardVM: PayCardVM
    @ObservedObject var payListVM: PayListVM
    @ObservedObject var settingVM: SettingVM

    var body: some View {
        VStack {
            TabView(selection: $vm.selection) {
                PayCardScreenView(vm: payCardVM)
                    .tag(TabType.card)
                    .background {
                        if !isTabBarHidden {
                            HideTabBar {
                                print("Hidden")
                                isTabBarHidden = true
                            }
                        }
                    }
                PayListScreenView(vm: payListVM)
                    .tag(TabType.list)
                SettingScreenView(vm: settingVM)
                    .tag(TabType.settings)                    
            }
            CustomTabBar(tabType: $vm.selection)
        }
        .navigationBarBackButtonHidden()
    }
}


struct HideTabBar: UIViewRepresentable {
    var result: () -> ()

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear

        DispatchQueue.main.async {
            if let tabController = view.tabController {
                tabController.tabBar.isHidden = true
                result()
            }
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}

extension UIView {
    var tabController: UITabBarController? {
        if let controller = sequence(first: self, next: {
            $0.next
        }).first(where: { $0 is UITabBarController }) as? UITabBarController {
            return controller
        }

        return nil
    }
}

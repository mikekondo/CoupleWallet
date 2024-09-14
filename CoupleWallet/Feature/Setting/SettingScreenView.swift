import SwiftUI

struct SettingScreenView<VM: SettingViewModel>: View {
    @StateObject var vm: VM

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text("自分の名前")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(vm.myName)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.secondary)
                Divider()
                    .background(Color.secondary)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("パートナーの名前")
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(vm.partnerName)
                    .font(.title3)
                    .bold()
                    .foregroundColor(.secondary)
                Divider()
                    .background(Color.secondary)
            }

            VStack(spacing: 16) {
                Button {
                    Task {
                        await vm.didTapDeleteAccount()
                    }
                } label: {
                    Text("アカウント削除")
                        .font(.body)
                        .fontWeight(.semibold)
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 2)
                        )
                }
                Button {
                    vm.didTapDisplayShareCode()
                } label: {
                    Text("共有コード表示")
                        .font(.body)
                        .fontWeight(.semibold)
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(Color.clear)
                        .foregroundColor(.black)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.black, lineWidth: 2)
                        )
                }
            }
        }
        .padding(24)        
        .alert(alertType: $vm.alertType)
    }
}

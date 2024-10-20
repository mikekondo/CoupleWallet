import SwiftUI

struct SettingScreenView<VM: SettingViewModel>: View {
    @StateObject var vm: VM

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    myNameView
                    partnerNameView
                    buttonView
                }
                .padding(.horizontal, 24)
            }
            Spacer()
            AddMobBannerContentView()
        }
        .navigationTitle("設定")
        .alert(alertType: $vm.alertType)
    }
}

extension SettingScreenView {
    var myNameView: some View {
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
        .padding(.vertical, 12)
    }

    var partnerNameView: some View {
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
        .padding(.vertical, 12)
    }

    var buttonView: some View {
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
                    .foregroundStyle(Color.white.gradient)
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
        .padding(.vertical, 24)
    }
}

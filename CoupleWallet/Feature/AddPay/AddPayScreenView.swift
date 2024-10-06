import SwiftUI

struct AddPayScreenView<VM: AddPayViewModel>: View {
    @StateObject var vm: VM
    var body: some View {
        addView
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .loading(isPresented: $vm.shouldShowLoading)
            .alert(alertType: $vm.alertType)
            .safeAreaInset(edge: .top) {
                headerView
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    Task {
                        await vm.didTapAdd()
                    }
                } label: {
                    Text("追加する")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.gradient, in: RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .padding(16)
            }
    }
}

extension AddPayScreenView {
    var headerView: some View {
        HStack(spacing: 0) {
            Button {
                vm.didTapCloseButton()
            } label: {
                Image(systemName: "xmark")
                    .font(.title2.bold())
                    .foregroundStyle(Color.black.gradient)
            }
            Text("立替記録を追加")
                .font(.title2.bold())
                .foregroundStyle(Color.black.gradient)
                .frame(maxWidth: .infinity)
            // 「立替記録を追加」を中央にするため、空のViewを配置
            Color.clear
                .frame(width: 24, height: 24)
        }
        .padding(16)
    }

    var addView: some View {
        VStack(spacing: 32) {
            nameView
            titleView
            priceView
        }        
        .background(Color.white)
    }

    var nameView: some View {
        VStack(spacing: 16) {
            Text("支払った人")
                .font(.title3.bold())
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 16) {
                Button {
                    vm.didTapMyName()
                } label: {
                    Text(vm.myName)
                        .font(.body.bold())
                        .foregroundColor(.white)
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(vm.isPayByMe ? Color.black.gradient : Color.gray.gradient, in: RoundedRectangle(cornerRadius: 8))
                }
                Button {
                    vm.didTapPartnerName()
                } label: {
                    Text(vm.partnerName)
                        .font(.body.bold())
                        .foregroundColor(.white)
                        .padding(12)
                        .frame(maxWidth: .infinity)
                        .background(vm.isPayByMe ? Color.gray.gradient : Color.black.gradient, in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }

    var titleView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("タイトル")
                .font(.title3.bold())
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("タイトルを入力してください（任意）", text: $vm.payTitle)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(12)
                .background(Color(white: 0.95), in: RoundedRectangle(cornerRadius: 8))
        }
    }

    var priceView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("金額")
                .font(.title3.bold())
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("金額を入力してください", text: $vm.payPrice)
                .keyboardType(.numberPad)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(12)
                .background(Color(white: 0.95), in: RoundedRectangle(cornerRadius: 8))
        }
    }
}

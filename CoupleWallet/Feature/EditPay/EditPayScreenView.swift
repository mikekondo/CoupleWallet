import SwiftUI

struct EditPayScreenView<VM: EditPayViewModel>: View {
    enum FocusedField {
        case price, title
    }

    @StateObject var vm: VM
    @FocusState private var focusedField: FocusedField?

    var body: some View {
        contentView
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .loading(isPresented: $vm.shouldShowLoading)
            .alert(alertType: $vm.alertType)
            .safeAreaInset(edge: .top) {
                headerView
            }
            .safeAreaInset(edge: .bottom) {
                editButtonView
            }
            .onAppear {
                focusedField = .price
            }
    }
}

extension EditPayScreenView {
    private var headerView: some View {
        HStack(spacing: 0) {
            Button {
                vm.didTapCloseButton()
            } label: {
                Image(systemName: "xmark")
                    .font(.title3.bold())
                    .foregroundStyle(Color.black.gradient)
            }
            Text("立替記録を編集")
                .font(.title3.bold())
                .foregroundStyle(Color.black.gradient)
                .frame(maxWidth: .infinity)
            // 「立替記録を追加」を中央にするため、空のViewを配置
            Color.clear
                .frame(width: 24, height: 24)
        }
        .padding(12)
    }
    private var contentView: some View {
        VStack(spacing: 16) {
            nameView
            priceView
            titleView
            dateView
        }
        .background(Color.white)
    }

    private var editButtonView: some View {
        Button {
            Task {
                await vm.didTapEditButton()
            }
        } label: {
            Text("変更する")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(height: 44)
                .frame(maxWidth: .infinity)
                .background(Color.black.gradient, in: RoundedRectangle(cornerRadius: 12))
                .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .padding(16)
    }

    private var nameView: some View {
        VStack(spacing: 8) {
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

    private var titleView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("件名")
                .font(.title3.bold())
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("件名を入力してください", text: $vm.payTitle)
                .textFieldStyle(PlainTextFieldStyle())
                .focused($focusedField, equals: .title)
                .padding(12)
                .background(Color(white: 0.95), in: RoundedRectangle(cornerRadius: 8))
        }
    }

    private var priceView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("金額")
                .font(.title3.bold())
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("金額を入力してください", text: $vm.payPrice)
                .keyboardType(.numberPad)
                .textFieldStyle(PlainTextFieldStyle())
                .focused($focusedField, equals: .price)
                .padding(12)
                .background(Color(white: 0.95), in: RoundedRectangle(cornerRadius: 8))
        }
    }

    private var dateView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("日付")
                .font(.title3.bold())
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            DatePicker("日付を選択してください", selection: $vm.payDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .environment(\.locale, Locale(identifier: "ja_JP"))
                .padding(12)
                .background(Color(white: 0.95), in: RoundedRectangle(cornerRadius: 8))
        }
    }
}

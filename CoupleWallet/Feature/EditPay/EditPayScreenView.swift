import SwiftUI

struct EditPayScreenView<VM: EditPayViewModel>: View {
    @StateObject var vm: VM

    var body: some View {
        editView
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .loading(isPresented: $vm.shouldShowLoading)
            .alert(alertType: $vm.alertType)
            .safeAreaInset(edge: .bottom) {
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
    }
}

extension EditPayScreenView {
    private var editView: some View {
        VStack(spacing: 32) {
            nameView
            titleView
            priceView
        }
        .background(Color.white)
    }

    private var nameView: some View {
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

    private var titleView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("件名")
                .font(.title3.bold())
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading)
            TextField("件名を入力してください", text: $vm.payTitle)
                .textFieldStyle(PlainTextFieldStyle())
                .padding(12)
                .background(Color(white: 0.95), in: RoundedRectangle(cornerRadius: 8))
        }
    }

    private var priceView: some View {
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

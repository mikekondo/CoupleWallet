import SwiftUI

struct AddPayScreenView<VM: AddPayViewModel>: View {
    @StateObject var vm: VM
    var body: some View {
        addView
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .loading(isPresented: $vm.shouldShowLoading)
            .background(Color.white)
            .safeAreaInset(edge: .bottom) {
                Button {
                    Task { @MainActor in
                        await vm.didTapAdd()
                    }
                } label: {
                    Text("追加する")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(height: 50)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.gradient)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .padding(16)
            }
    }
}

extension AddPayScreenView {
    var addView: some View {
        VStack(spacing: 24) {
            HStack(spacing: 16) {
                Button {
                    vm.didTapMyName()
                } label: {
                    Text(vm.myName)
                        .font(.body.bold())
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(vm.isPayByMe ? Color.black.gradient : Color.gray.gradient)
                        .cornerRadius(8)
                }
                Button {
                    vm.didTapPartnerName()
                } label: {
                    Text(vm.partnerName)
                        .font(.body.bold())
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(vm.isPayByMe ? Color.gray.gradient : Color.black.gradient)
                        .cornerRadius(8)
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("件名")
                    .font(.headline)
                    .foregroundColor(.black)
                TextField("件名を入力してください", text: $vm.payTitle)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(12)
                    .background(Color(white: 0.95))
                    .cornerRadius(8)
            }
            VStack(alignment: .leading, spacing: 8) {
                Text("金額")
                    .font(.headline)
                    .foregroundColor(.black)
                TextField("金額を入力してください", text: $vm.payPrice)
                    .keyboardType(.numberPad)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(12)
                    .background(Color(white: 0.95))
                    .cornerRadius(8)
            }
        }
        .padding(.vertical, 20)
        .background(Color.white)
    }
}

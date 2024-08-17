import SwiftUI

struct EditPayScreenView<VM: EditPayViewModel>: View {
    @StateObject var vm: VM

    var body: some View {
        editView
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .safeAreaInset(edge: .bottom) {
                Button {
                    Task { 
                        await vm.didTapEditButton()
                    }                    
                } label: {
                    Text("変更する")
                        .font(.title)
                        .foregroundStyle(Color.white)
                        .frame(height: 44)
                        .frame(maxWidth: .infinity)
                        .background(Color.black, in: RoundedRectangle(cornerRadius: 8))
                }
                .padding(16)
            }
    }
}

extension EditPayScreenView {
    private var editView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Button {
                    // TODO: action
                } label: {
                    Text("マイク")
                }
                Button {
                    // TODO: action
                } label: {
                    Text("れいちゃん")
                }
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("件名")
                    .font(.title)
                    .foregroundStyle(Color.black)
                TextField("件名を入力してください", text: $vm.payTitle)
                    .textFieldStyle(.roundedBorder)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text("金額")
                    .font(.title)
                    .foregroundStyle(Color.black)
                TextField("金額を入力してください", text: $vm.payPrice)
                    .textFieldStyle(.roundedBorder)
            }
        }
    }
}

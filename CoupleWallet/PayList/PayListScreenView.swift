import SwiftUI

struct PayListScreenView<VM: PayListViewModel>: View {
    @StateObject var vm: VM
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(vm.payViewDataList) { payViewData in
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(payViewData.title)
                                .font(.callout)
                                .foregroundStyle(Color.black)
                            Text(payViewData.byName)
                                .font(.callout)
                                .foregroundStyle(Color.gray)
                            Text(payViewData.dateText)
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        HStack(spacing: 16) {
                            Text(payViewData.priceText)
                                .font(.title3)
                                .foregroundStyle(Color.black)
                            Button {
                                // TODO: 編集
                            } label: {
                                Image(systemName: "ellipsis")
                                    .foregroundStyle(Color.gray)
                            }
                        }
                    }
                    Divider()
                }
                .padding(.horizontal, 16)
            }
            .onAppear {
                Task { @MainActor in
                    await vm.fetchPayList()
                }
            }
        }
    }
}

#Preview {
    PayListScreenView(vm: PayListViewModelImpl())
}


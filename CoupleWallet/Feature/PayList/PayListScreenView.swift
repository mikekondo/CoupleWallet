import SwiftUI

struct PayListScreenView<VM: PayListViewModel>: View {
    @StateObject var vm: VM
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(vm.payViewDataList) { viewData in
                    Button {
                        vm.didTapPayCell(id: viewData.id)
                    } label: {
                        payCell(viewData: viewData)
                    }
                    Divider()
                }
                .padding(.horizontal, 16)
            }
        }
        .refreshable {
            Task { @MainActor in
                await vm.pullToReflesh()
            }
        }
        .onViewDidLoad() {
            Task { @MainActor in
                await vm.onViewDidLoad()
            }
        }
        .loading(isPresented: $vm.shouldShowLoading)
    }
}

extension PayListScreenView {
    func payCell(viewData: PayViewData) -> some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewData.title)
                    .font(.callout)
                    .foregroundStyle(Color.black)
                Text(viewData.byName)
                    .font(.callout)
                    .foregroundStyle(Color.gray)
                Text(viewData.dateText)
                    .font(.caption2)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 16) {
                Text(viewData.priceText)
                    .font(.title3)
                    .foregroundStyle(Color.black)
                Menu {
                    Button {
                        Task { @MainActor in
                            await vm.didTapDeleteButton(id: viewData.id)
                        }
                    } label: {
                        Text("削除")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Color.gray)
                }
            }
        }
    }
}

#Preview {
    PayListScreenView(vm: PayListViewModelImpl())
}


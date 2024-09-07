import SwiftUI

struct PayListScreenView<VM: PayListViewModel>: View {
    @StateObject var vm: VM
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(vm.payViewDataList) { viewData in
                    Button {
                        vm.didTapPayCell(id: viewData.id)
                    } label: {
                        payCell(viewData: viewData)
                    }
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
                    .padding(.horizontal, 16)
                }
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
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.black)
                Text(viewData.byName)
                    .font(.callout)
                    .foregroundStyle(Color.gray)
                Text(viewData.dateText)
                    .font(.caption2)
                    .foregroundStyle(Color.gray.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 16) {
                Text(viewData.priceText)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.black)
                Menu {
                    Button {
                        Task { @MainActor in
                            await vm.didTapDeleteButton(id: viewData.id)
                        }
                    } label: {
                        Label("削除", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Color.gray)
                        .padding()
                }
                .background(Color.white)
                .cornerRadius(8)
            }
        }
        .padding()
    }
}

#Preview {
    PayListScreenView(vm: PayListViewModelImpl())
}

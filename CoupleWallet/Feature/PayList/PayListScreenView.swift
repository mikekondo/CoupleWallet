import SwiftUI
import Algorithms

struct PayListScreenView<VM: PayListViewModel>: View {
    @StateObject var vm: VM

    var body: some View {
        rootView
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
    @ViewBuilder
    private var rootView: some View {
        VStack(spacing: 0) {
            customNavigationBar
            filterDateView
            switch vm.payListViewType {
            case .content:
                contentView
            case .error:
                errorView
            case .zeromatch:
                zeroMatchView
            }
            Spacer()
            AddMobBannerContentView()
        }
    }

    private var customNavigationBar: some View {
        HStack(spacing: 0) {
            Text("立替リスト")
                .font(.title3.bold())
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity)
                .padding()
        }
    }

    private var filterDateView: some View {
        Picker("", selection: $vm.filterDateText) {
            ForEach(vm.recentSixMonthsDateTextList, id: \.self) { text in
                Text(text)
                    .tag(text)
            }
            .pickerStyle(.menu)
            .onChange(of: vm.filterDateText) { _, _ in
                Task {
                    await vm.updatePayList()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var zeroMatchView: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray.and.arrow.down")
                .resizable()
                .frame(width: 60, height: 60)
                .foregroundStyle(.black)
            Text("立替記録がありません")
                .font(.title3.bold())
                .foregroundStyle(.black)
        }
        .background(Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var errorView: some View {
        VStack(spacing: 16) {
            Text("データの読み込み中にエラーが発生しました")
                .font(.callout.bold())
                .foregroundStyle(.black)
            Button(action: {
                Task {
                    await vm.pullToReflesh()
                }
            }) {
                Text("再試行")
                    .font(.title3.bold())
                    .padding(16)
                    .foregroundStyle(.white)
                    .background(Color.black.gradient, in: RoundedRectangle(cornerRadius: 8))
            }
        }
        .background(Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var contentView: some View {
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
    }

    private func payCell(viewData: PayViewData) -> some View {
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
                            .font(.title3.bold())
                            .foregroundStyle(Color.red)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundStyle(Color.gray)
                        .padding()
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    PayListScreenView(vm: PayListViewModelImpl())
}

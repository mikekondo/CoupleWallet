import SwiftUI

@MainActor struct PayCardScreenView<VM: PayCardViewModel>: View {
    @StateObject var vm: VM
    var body: some View {
        VStack(spacing: 28) {
            cardView
                .padding(.horizontal, 16)
            ScrollView {
                payListView
                    .padding(.horizontal, 16)
            }
            .background(Color.white)
            .onViewDidLoad {
                Task {
                    await vm.viewDidLoad()
                }
            }
            .refreshable {
                Task {
                    await vm.pullToReflesh()
                }
            }
        }
        .overlay(alignment: .bottomTrailing) {
            addView
                .padding(24)
        }
        .loading(isPresented: $vm.shouldShowLoading)
    }
}

extension PayCardScreenView {
    private var cardView: some View {
        VStack(spacing: 0) {
            if vm.shouldShowPayView {
                payView
                    .transition(.reverseFlip)
            } else {
                totalView
                    .transition(.flip)
            }
        }
    }

    @ViewBuilder
    private var payView: some View {
        if let viewData = vm.payBalanceCardViewData {
            VStack(alignment: .leading, spacing: 16) {
                Text(viewData.nameText)
                    .font(.title2.bold())
                    .foregroundColor(.black)
                HStack(spacing: 16) {
                    Text(viewData.priceText)
                        .font(.title.bold())
                        .foregroundStyle(Color.black.gradient)
                        .animation(.bouncy)
                    Button {
                        Task { @MainActor in
                            await vm.didTapUpdatePayBalanceButton()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .font(.title3.bold())
                            .foregroundStyle(Color.gray)
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 8)
            .overlay(alignment: .bottomTrailing) {
                Text("Tap")
                    .font(.body.bold())
                    .foregroundStyle(Color.black)
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            vm.didTapCardView()
                        }
                    }
                    .padding(16)
            }
        }
    }

    private var totalView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("8月の合計金額")
                .font(.title2.bold())
                .foregroundColor(.black)
            HStack(spacing: 16) {
                Text("1,000円")
                    .font(.title.bold())
                    .foregroundColor(.black)
                Button {
                    Task { @MainActor in
                        await vm.didTapUpdatePayBalanceButton()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .font(.title3.bold())
                        .foregroundStyle(Color.gray)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.15), radius: 12, x: 0, y: 8)
        .overlay(alignment: .bottomTrailing) {
            Text("Tap")
                .font(.body.bold())
                .foregroundStyle(Color.black)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        vm.didTapCardView()
                    }
                }
                .padding(16)
        }
    }

    private var addView: some View {
        Button {
            vm.didTapAddButton()
        } label: {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
        }
        .foregroundStyle(Color.black.gradient)
    }

    private var payListView: some View {
        VStack(spacing: 8) {
            Text("立替リスト")
                .font(.title3.bold())
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 4)
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(vm.payViewDataList) { viewData in
                    payCell(viewData: viewData)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.gray.opacity(0.2), radius: 5, x: 0, y: 2)
                        .onTapGesture {
                            vm.didTapPayCell(id: viewData.id)                        
                        }
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
                        Task {
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
                }
            }
        }
        .padding()
    }
}

import SwiftUI

@MainActor struct PayCardScreenView<VM: PayCardViewModel>: View {
    @StateObject var vm: VM
    var body: some View {
        VStack(spacing: 28) {
            cardView
                .padding(.horizontal, 16)
            if vm.shouldShowPartnerLinkageView {
                partnerLinkageView
                    .padding(.horizontal, 16)
            }
            ScrollView {
                switch vm.payListViewType {
                case .content:
                    payListView
                case .zeroMatch, .error:
                    EmptyView()
                }
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
        .background(rootView)
        .overlay(alignment: .bottomTrailing) {
            addView
                .padding(.trailing, 16)
                .padding(.bottom, 8)
        }
        .loading(isPresented: $vm.shouldShowLoading)
        .alert(alertType: $vm.alertType)        
    }
}

extension PayCardScreenView {
    @ViewBuilder
    private var rootView: some View {
        switch vm.payListViewType {
        case .content:
            EmptyView()
        case .error:
            errorView
        case .zeroMatch:
            zeroMatchView
        }
    }
    // パートナー連携訴求モジュール
    private var partnerLinkageView: some View {
        VStack(spacing: 16) {
            HStack(spacing: 8) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.black.gradient)
                VStack(alignment: .leading, spacing: 4) {
                    Text("パートナーと連携")
                        .font(.headline.bold())
                        .foregroundStyle(.black)
                    Text("立替をパートナーと管理するために、連携しましょう")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineSpacing(6)
                }
                .frame(maxWidth: .infinity)
                Button {
                    vm.didTapPartnerLinkageButton()
                } label: {
                    Text("今すぐ連携")
                        .font(.body.bold())
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(Color.gray.gradient, in: RoundedRectangle(cornerRadius: 8))
                }
            }
        }
        .padding(8)
        .frame(maxWidth: .infinity)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
        }
    }
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
            VStack(alignment: .leading, spacing: 0) {
                Text("貸し借り")
                    .font(.headline.bold())
                    .foregroundStyle(.white)
                    .padding(.leading, 8)
                    .frame(height: 40)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 8)
                    .background(Color.black.gradient)
                    .clipShape(RoundedCorner(radius: 12, corners: [.topLeft, .topRight]))
                VStack(alignment: .leading, spacing: 16) {
                    Text(viewData.nameText)
                        .font(.title2.bold())
                        .foregroundStyle(.black)
                    HStack(spacing: 16) {
                        Text(viewData.priceText)
                            .font(.title.bold())
                            .foregroundStyle(Color.black.gradient)
                            .animation(.default, value: viewData.priceText)
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
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.gradient)
                        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
                )
            }
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
        VStack(alignment: .leading, spacing: 0) {
            Text("支出")
                .font(.headline.bold())
                .padding(.leading, 8)
                .foregroundStyle(.white)
                .frame(height: 40)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 8)
                .background(Color.black.gradient)
                .clipShape(RoundedCorner(radius: 12, corners: [.topLeft, .topRight]))
            VStack(alignment: .leading, spacing: 16) {
                Text("8月の合計金額")
                    .font(.title2.bold())
                    .foregroundStyle(.black)
                HStack(spacing: 16) {
                    Text("1,000円")
                        .font(.title.bold())
                        .foregroundStyle(.black)
                    Button {
                        Task { @MainActor in
                            await vm.didTapUpdatePayBalanceButton()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.body.bold())
                            .foregroundStyle(Color.gray)
                    }
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.gradient)
                    .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
            )
        }
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
                .padding(.leading, 4)
            .frame(maxWidth: .infinity, alignment: .leading)
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
        .padding(.horizontal, 16)
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
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
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
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

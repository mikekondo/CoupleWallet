import SwiftUI

@MainActor struct PayCardScreenView<VM: PayCardViewModel>: View {
    @StateObject var vm: VM
    var body: some View {
        cardView
            .padding(.horizontal, 36)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)
            .onViewDidLoad {
                Task {
                    await vm.viewDidLoad()
                }
            }
            .overlay(alignment: .bottomTrailing) {
                addView
                    .padding(24)
            }
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
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(viewData.nameText)
                        .font(.title2.bold())
                        .foregroundColor(.black)
                    HStack(spacing: 16) {
                        Text(viewData.priceText)
                            .font(.largeTitle.bold())
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
        HStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 16) {
                Text("8月の合計金額")
                    .font(.title2.bold())
                    .foregroundColor(.black)
                HStack(spacing: 16) {
                    Text("1,000円")
                        .font(.largeTitle.bold())
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
}

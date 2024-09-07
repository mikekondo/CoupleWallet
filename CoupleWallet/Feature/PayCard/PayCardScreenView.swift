import SwiftUI

@MainActor struct PayCardScreenView<VM: PayCardViewModel>: View {
    @StateObject var vm: VM
    var body: some View {
        cardView
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
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 10)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.8)) {
                vm.didTapCardView()
            }
        }
    }

    @ViewBuilder
    private var payView: some View {
        if let viewData = vm.payBalanceCardViewData {
            VStack(alignment: .leading, spacing: 8) {
                Text(viewData.nameText)
                    .font(.title2.bold())
                    .foregroundColor(.black)
                Text(viewData.priceText)
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.black.gradient)
            }
            .padding(24)
            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 8)
        }
    }

    private var totalView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("8月の合計金額")
                .font(.title2.bold())
                .foregroundColor(.black)
            Text("1,000円")
                .font(.largeTitle.bold())
                .foregroundColor(.black)
        }
        .padding(24)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white))
        .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 8)
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

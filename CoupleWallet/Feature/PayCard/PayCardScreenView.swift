import SwiftUI

/// 立替の計算結果を表示する画面
@MainActor struct PayCardScreenView<VM: PayCardViewModel>: View {
    @StateObject var vm: VM
    var body: some View {
        cardView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
        .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 8)
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
                    .font(.title)
                    .foregroundStyle(Color.black.gradient)
                Text(viewData.priceText)
                    .font(.title)
                    .foregroundStyle(Color.black)
            }
            .overlay(alignment: .bottomTrailing) {
                Text("Tap")
                    .font(.subheadline)
                    .foregroundStyle(Color.black.gradient)
                    .padding(8)
            }
            .padding(24)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.black, lineWidth: 4)
                    .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 6)
            }
        }
    }

    private var totalView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("8月の合計金額")
                .font(.title)
                .foregroundStyle(Color.black)
            Text("1,000円")
                .font(.title)
                .foregroundStyle(Color.black)
        }
        .overlay(alignment: .bottomTrailing) {
            Text("Tap")
                .font(.subheadline)
                .foregroundStyle(Color.black)
                .offset(x: 10, y: 10)
        }
        .padding(24)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.black, lineWidth: 4)
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

#Preview {
    PayCardScreenView(vm: PayCardViewModelImpl())
}

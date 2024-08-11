import SwiftUI

struct PayListScreenView: View {
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(payDatas) { payData in
                    HStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(payData.title)
                                .font(.callout)
                                .foregroundStyle(Color.black)
                            Text(payData.name + "が立替え")
                                .font(.callout)
                                .foregroundStyle(Color.gray)
                            Text(payData.date.formatted(.dateTime))
                                .font(.caption2)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        Text("\(payData.price)円")
                            .font(.title3)
                            .foregroundStyle(Color.black)
                    }
                    Divider()
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

#Preview {
    PayListScreenView()
}


import SwiftUI

struct CustomTabBar: View {
    var activeForeground: Color = .white
    var activeBackground: Color = .black
    @Binding var tabType: TabType

    var body: some View {
        HStack(spacing: 0) {
            ForEach(TabType.allCases, id: \.rawValue) { tab in
                Button {
                    tabType = tab
                    HapticFeedbackManager.shared.play(.impact(.heavy))
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: tab.rawValue)
                            .font(.title3.bold())
                            .frame(width: 30, height: 30)
                        if tabType == tab {
                            Text(tab.title)
                                .font(.caption.bold())
                        }
                    }
                    .foregroundStyle(tabType == tab ? activeForeground : .gray)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 24)
                    .background {
                        if tabType == tab {
                            Capsule()
                                .fill(activeBackground.gradient)
                        }
                    }
                }
            }
        }
        .animation(.smooth(duration: 0.3, extraBounce: 0), value: tabType)
    }
}

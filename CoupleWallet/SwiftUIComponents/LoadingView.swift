import SwiftUI
/// ローディングView
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("読み込み中...")
                .font(.headline)
        }
        .padding(30)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 10)
    }
}

/// LoadingViewを使用できるモディファイア
struct LoadingModifier: ViewModifier {
    @Binding var isPresented: Bool

    func body(content: Content) -> some View {
        content
            .overlay(
                ZStack {
                    if isPresented {                       
                        LoadingView()
                    }
                }
            )
    }
}

/// ViewDidLoad
struct ViewDidLoadModifier: ViewModifier {
    @State private var viewDidLoad = false
    let action: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .onAppear {
                if viewDidLoad == false {
                    viewDidLoad = true
                    action?()
                }
            }
    }
}

// MARK: loading
extension View {
    @MainActor func loading(isPresented: Binding<Bool>) -> some View {
        self.modifier(LoadingModifier(isPresented: isPresented))
    }
}

// MARK: ViewDidLoad
extension View {
    func onViewDidLoad(perform action: (() -> Void)? = nil) -> some View {
        self.modifier(ViewDidLoadModifier(action: action))
    }
}

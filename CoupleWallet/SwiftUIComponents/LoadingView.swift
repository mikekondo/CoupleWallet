import SwiftUI
/// ローディングView
struct LoadingView: View {
    var body: some View {
        ProgressView()
            .progressViewStyle(.circular)
            .padding()
            .tint(Color.white)
            .background(Color.black.gradient, in: RoundedRectangle(cornerRadius: 8))
            .opacity(0.6)
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

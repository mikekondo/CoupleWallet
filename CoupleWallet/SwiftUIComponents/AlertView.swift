import SwiftUI

struct AlertView: ViewModifier {
    @Binding var alertType: AlertType?
    var isPresented: Binding<Bool> {
        Binding<Bool>(
            get: { alertType != nil },
            set: {
                if !$0 {
                    alertType = nil
                }
            }
        )
    }

    init(
        alertType: Binding<AlertType?>
    ) {
        self._alertType = alertType
    }

    func body(content: Content) -> some View {
        content
            .alert(alertType?.title ?? "", isPresented: isPresented) {
                if let buttons = alertType?.buttons {
                    ForEach(Array(buttons.enumerated()), id: \.offset) { _, button in
                        Button(button.title, role: button.role, action: { button.action?() })
                            .bold(isBold: button.isBold)
                    }
                }
            } message: {
                Text(alertType?.message ?? "")
            }
    }
}

public extension View {
    /// alertを表示するモディファイア
    ///
    ///     Text("")
    ///         .alert($alertType)
    ///
    /// - Parameter alertType: AlertType
    /// - Returns: some View
    func alert(
        alertType: Binding<AlertType?>
    ) -> some View {
        self.modifier(
            AlertView(
                alertType: alertType
            )
        )
    }
}

/// OKボタンを太字にするためだけのViewModifier/// OKボタンを太字にするためだけのViewModifier
private struct OKButtonModifier: ViewModifier {
    let isBold: Bool
    func body(content: Content) -> some View {
        if isBold {
            content.keyboardShortcut(.defaultAction)
        } else {
            content
        }
    }
}

private extension View {
    func bold(isBold: Bool) -> some View {
        self.modifier(OKButtonModifier(isBold: isBold))
    }
}

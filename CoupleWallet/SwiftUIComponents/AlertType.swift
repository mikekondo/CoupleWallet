import SwiftUI

@MainActor
public struct AlertType: Equatable {
    public let title: String
    public let message: String
    public let buttons: [AlertButtonType]

    nonisolated public static func == (lhs: AlertType, rhs: AlertType) -> Bool {
        return lhs.title == rhs.title && lhs.message == rhs.message && lhs.buttons == rhs.buttons
    }

    @MainActor public init(
        title: String = "エラー",
        message: String,
        buttons: [AlertButtonType]
    ) {
        self.title = title
        self.message = message
        self.buttons = buttons
    }

    @MainActor public init(
        title: String = "エラー",
        message: String
    ) {
        self.title = title
        self.message = message
        self.buttons = [.init(title: "OK", isBold: true)]
    }
}

@MainActor
public struct AlertButtonType: Equatable {
    nonisolated public static func == (lhs: AlertButtonType, rhs: AlertButtonType) -> Bool {
        return lhs.title == rhs.title && lhs.role == rhs.role
    }

    public let title: String
    public let role: ButtonRole?
    public let action: (() -> Void)?
    public let isBold: Bool

    public init(title: String, role: ButtonRole? = nil, action: (() -> Void)? = nil, isBold: Bool = false) {
        self.title = title
        self.role = role
        self.action = action
        self.isBold = isBold
    }

    public init(title: String, role: ButtonRole? = nil, action: (@MainActor () async -> Void)? = nil, isBold: Bool = false) {
        self.title = title
        self.role = role
        self.action = {
            Task {
                await action?()
            }
        }
        self.isBold = isBold
    }
}

import Foundation

@MainActor
final class SettingCoordinator {
    let transitioner: Transitioner

    init(transitioner: Transitioner) {
        self.transitioner = transitioner
    }
}

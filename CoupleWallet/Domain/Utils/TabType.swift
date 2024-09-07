import Foundation

enum TabType: String, CaseIterable {
    case home = "house"
    case search = "magnifyingglass"
    case settings = "gearshape"

    var title: String {
        switch self {
        case .home:
            return "立替"
        case .search:
            return "リスト"
        case .settings:
            return "設定"
        }
    }
}

import Foundation

// TODO: 命名はあとで直す
enum TabType: String, CaseIterable {
    case home = "dollarsign.circle"
    // case search = "list.dash.header.rectangle"
    case settings = "gearshape"

    var title: String {
        switch self {
        case .home:
            return "立替"
//        case .search:
//            return "リスト"
        case .settings:
            return "設定"
        }
    }
}

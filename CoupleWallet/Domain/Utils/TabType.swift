import Foundation

// TODO: 命名はあとで直す
enum TabType: String, CaseIterable {
    case card = "dollarsign.circle"
    case list = "list.dash.header.rectangle"
    case settings = "gearshape"

    var title: String {
        switch self {
        case .card:
            return "立替"
        case .list:
            return "リスト"
        case .settings:
            return "設定"
        }
    }
}

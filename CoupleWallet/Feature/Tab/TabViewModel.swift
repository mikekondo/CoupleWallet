import Foundation

@MainActor protocol TabViewModel: ObservableObject {
    var selection: TabType { get set }
    var isTabBarHidden: Bool { get set }
}

final class TabViewModelImpl: TabViewModel {
    @Published var selection: TabType = .card
    @Published var isTabBarHidden: Bool = false
}



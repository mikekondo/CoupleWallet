import Foundation

protocol TabViewModel: ObservableObject {
    var selection: Int { get set }
}

final class TabViewModelImpl: TabViewModel {
    @Published var selection: Int = 0

    
}



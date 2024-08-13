import Foundation

protocol EditPayViewModel: ObservableObject {

}

final class EditPayViewModelImpl: EditPayViewModel {
    let payData: PayData

    init(payData: PayData) {
        self.payData = payData
    }
}

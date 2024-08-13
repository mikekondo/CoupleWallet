import SwiftUI

struct EditPayScreenView<VM: EditPayViewModel>: View {
    @StateObject var vm: VM

    var body: some View {
        VStack(spacing: 8) {
            Text("editPay")
        }
    }
}

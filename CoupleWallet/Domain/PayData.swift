import Foundation

struct PayData: Identifiable {
    let title: String
    let name: String
    let price: Int
    let date: Date
    var id: String {
        UUID().uuidString
    }
}

let payDatas: [PayData] = [
    .init(title: "やきにく", name: "マイク", price: 1000, date: Date()),
    .init(title: "すし", name: "れいちゃん", price: 10390, date: Date()),
    .init(title: "ラーメン", name: "マイク", price: 24231, date: Date())
]

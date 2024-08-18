import Foundation

/// DBに登録する支払い金額のデータ構造体
struct PayData: Identifiable {
    let id: String
    let title: String
    let byName: String
    let price: Int
    let date: Date
}

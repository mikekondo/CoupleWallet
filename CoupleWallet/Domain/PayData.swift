import Foundation
import FirebaseFirestore

/// DBに登録する支払い金額のデータ構造体
struct PayData: Codable {
    @DocumentID var id: String?
    var title: String
    var byName: String
    var price: Int
    var date: Date
}

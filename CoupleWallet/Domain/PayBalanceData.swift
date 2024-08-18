import Foundation

/// 支払いバランスを管理するEnum
/// 2人のユーザー間の立替払いにおける
/// 支払いのバランスを表現します。
enum PayBalanceType {
    case overPayment(payerName: String, receiverName: String, difference: Int)
    case equal
    case noData
}

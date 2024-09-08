import Foundation

// TODO: userName以外はオプショナルのほうがいいかも？パートナーと連携済みでない時取得できないから
protocol DataStorable {
    var shareCode: String? { get set }
    var userName: String { get set }
    var partnerName: String { get set }
    var isPartnerLink: Bool { get set }
}

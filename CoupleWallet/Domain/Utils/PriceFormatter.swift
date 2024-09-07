import Foundation

final class PriceFormatter {
    static let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        /**
         currencyStyleにすると円の手間に半角スペースが入ったり、
         フリマのスタイルと異なるので数字だけ整形する
         */
        formatter.numberStyle = .decimal
        formatter.groupingSize = 3
        formatter.groupingSeparator = ","
        return formatter
    }()

    public static func string(forPrice price: any PriceStringConvertible, sign: YenSign) -> String {
        let formattedString: String
        switch price {
        case let value as Int:
            formattedString = formatter.string(from: .init(value: value))!
        case let value as Int64:
            formattedString = formatter.string(from: .init(value: value))!
        case let value as Double:
            formattedString = formatter.string(from: .init(value: value))!
        case let value as Float:
            formattedString = formatter.string(from: .init(value: value))!
        default:
            assertionFailure("Invalid price type.")
            formattedString = ""
        }
        switch sign {
        case .tail:
            return formattedString + "円"
        case .tailPt:
            return formattedString + "pt"
        case .none:
            return formattedString
        }
    }
}

public enum YenSign {
    case tail
    case tailPt
    case none
}

public protocol PriceStringConvertible {}

extension Int: PriceStringConvertible {}
extension Int64: PriceStringConvertible {}
extension Double: PriceStringConvertible {}
extension Float: PriceStringConvertible {}

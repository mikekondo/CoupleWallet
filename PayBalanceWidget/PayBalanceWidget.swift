import WidgetKit
import SwiftUI
import FirebaseCore
import FirebaseFirestore

struct Provider: TimelineProvider {
    typealias Entry = SimpleEntry

    // Firebaseのセットアップ
    init() {
        FirebaseApp.configure()
    }

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), payBalanceText: "読み込み中")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), payBalanceText: "mikeがreiに1000円払う")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            var entries: [SimpleEntry] = []

            let currentDate = Date()

            // 非同期で立替情報を取得
            let payBalanceText = await fetchPayBalanceText()

            // タイムラインエントリを作成
            for hourOffset in 0 ..< 5 {
                let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
                let entry = SimpleEntry(date: entryDate, payBalanceText: payBalanceText)
                entries.append(entry)
            }

            let timeline = Timeline(entries: entries, policy: .atEnd)
            completion(timeline)
        }
    }

    // Firebaseから立替情報を取得する関数
    func fetchPayBalanceText() async -> String {
        let viewModel = PayBalanceWidgetViewModel()
        do {
            let payBalanceType = try await viewModel.getPayBalanceType()
            switch payBalanceType {
            case .overPayment(let payerName, let receiverName, let difference):
                return "\(payerName)が\(receiverName)に\(difference)円払う"
            case .equal:
                return "お互いに同額です"
            case .noData:
                return "データがありません"
            }
        } catch {
            return "エラーが発生しました"
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let payBalanceText: String
}

struct PayBalanceWidgetEntryView : View {
    var entry: SimpleEntry

    var body: some View {
        VStack(alignment: .leading) {
            Text("貸し借り")
                .bold()
            Text(entry.payBalanceText)
                .bold()
        }
        .padding()
    }
}

struct PayBalanceWidget: Widget {
    let kind: String = "PayBalanceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PayBalanceWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("立替")
        .description("立替状況を表示します")
        .supportedFamilies([.systemSmall, .accessoryRectangular])
    }
}

// PayBalanceWidgetViewModelに追加する変更は不要
struct PayBalanceWidgetViewModel {
    // 立替計算のロジック
    func getPayBalanceType() async throws -> PayBalanceType {
        let db = Firestore.firestore()
        var userDefaults = UserDefaults(suiteName: "group.com.couple.wallet")
        var shareCode = ""
        var userName = ""
        var partnerName = ""
        if let userDefaults = userDefaults {
            shareCode = userDefaults.string(forKey: "shareCode") ?? ""
            userName = userDefaults.string(forKey: "userName") ?? ""
            partnerName = userDefaults.string(forKey: "partnerName") ?? "パートナー"
        }

        let payDocuments = try await db
            .collection("users")
            .document(shareCode)
            .collection("pay")
            .getDocuments()
            .documents

        var myTotalPayPrice: Int = 0
        var partnerTotalPayPrice: Int = 0

        payDocuments.forEach { document in
            guard let price = document.get("price") as? Int,
                  let byName = document.get("byName") as? String else { return }
            if byName == userName {
                myTotalPayPrice += price
            } else if byName == partnerName {
                partnerTotalPayPrice += price
            }
        }

        var difference: Int = 0

        if myTotalPayPrice > partnerTotalPayPrice {
            difference = myTotalPayPrice - partnerTotalPayPrice
            return .overPayment(payerName: partnerName, receiverName: userName, difference: difference)
        } else if myTotalPayPrice < partnerTotalPayPrice {
            difference = partnerTotalPayPrice - myTotalPayPrice
            return .overPayment(payerName: userName, receiverName: partnerName, difference: difference)
        } else {
            return .equal
        }
    }
}

enum PayBalanceType {
    case overPayment(payerName: String, receiverName: String, difference: Int)
    case equal
    case noData
}

import WidgetKit
import SwiftUI

struct PayBalanceWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), emoji: "😀")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), emoji: "😀")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, emoji: "😀")
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
}

struct PayBalanceWidgetEntryView : View {
    var entry: PayBalanceWidgetProvider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)

            Text("Emoji:")
            Text(entry.emoji)
        }
    }
}

struct PayBalanceWidget: Widget {
    let kind: String = "PayBalanceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PayBalanceWidgetProvider()) { entry in
            if #available(iOS 17.0, *) {
                PayBalanceWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                PayBalanceWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("立替")
        .description("立替金額の情報を表示します")
        .supportedFamilies([.accessoryRectangular])
    }
}

#Preview(as: .systemSmall) {
    PayBalanceWidget()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀")
}

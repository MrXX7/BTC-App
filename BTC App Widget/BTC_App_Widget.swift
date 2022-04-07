//
//  BTC_App_Widget.swift
//  BTC App Widget
//
//  Created by Oncu Ohancan on 7.04.2022.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), data: .previewData, error: false)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), data: .previewData, error: false)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, data: .previewData, error: false)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    var data: BTCData
    var error: Bool
    
    enum DifferenceMode: String {
        
        case up = "up",
             down = "down",
             error = "error"
    }
    var diffMode: DifferenceMode {
        if error || data.difference == 0.0 {
            return .error
        } else if data.difference > 0.0 {
            return .up
        } else {
            return .down
        }
    }
    
    struct BTCData: Decodable {
        let price_24h: Double
        let volume_24h: Double
        let last_trade_price: Double
        
        var difference: Double { price_24h - last_trade_price }
        
        static let previewData = BTCData(price_24h: 42727.35, volume_24h: 2.51, last_trade_price: 43689.54)
        static let error = BTCData(price_24h: 0, volume_24h: 0, last_trade_price: 0)
    }
}

struct BTC_App_WidgetEntryView : View {
    
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) var scheme
    var entry: Provider.Entry

    var body: some View {
        ZStack {
            Image("bg")
                .resizable()
                .unredacted()
            
            HStack {
                VStack(alignment: .leading) {
                    header
                    Spacer()
                }
                .padding()
                Spacer()
            }
        }
    }
    var header: some View {
        Group {
         Text("BTC App")
                .bold()
                .font(family == .systemLarge ? .system(size: 40) : .title)
                .minimumScaleFactor(0.5)
         Text("Bitcoin")
        }
    }
}

@main
struct BTC_App_Widget: Widget {
    let kind: String = "BTC_App_Widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            BTC_App_WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("BTC Widget")
        .description("Track Bitcoin Prices Easily")
    }
}

struct BTC_App_Widget_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
        BTC_App_WidgetEntryView(entry: SimpleEntry(date: Date(), data: .previewData, error: false))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
            
            BTC_App_WidgetEntryView(entry: SimpleEntry(date: Date(), data: .previewData, error: false))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
            
        BTC_App_WidgetEntryView(entry: SimpleEntry(date: Date(), data: .previewData, error: false))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
        .environment(\.colorScheme, .light)
//        .redacted(reason: .placeholder)
}
}

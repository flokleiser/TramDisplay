////
////  TramDisplayWidget.swift
////  TramDisplayWidget
////
////  Created by Flo Kleiser on 15.02.2025.
////
//
//import WidgetKit
//import SwiftUI
//
//struct Provider: AppIntentTimelineProvider {
//    func placeholder(in context: Context) -> SimpleEntry {
//        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
//    }
//
//    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
//        SimpleEntry(date: Date(), configuration: configuration)
//    }
//    
//    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
//        var entries: [SimpleEntry] = []
//
//        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, configuration: configuration)
//            entries.append(entry)
//        }
//
//        return Timeline(entries: entries, policy: .atEnd)
//    }
//
////    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
////        // Generate a list containing the contexts this widget is relevant in.
////    }
//}
//
//struct SimpleEntry: TimelineEntry {
//    let date: Date
//    let configuration: ConfigurationAppIntent
//}
//
//struct TramDisplayWidgetEntryView : View {
//    var entry: Provider.Entry
//
//    var body: some View {
//        Text("Time:")
//        Text(entry.date, style: .time)
//
//        Text("Favorite Emoji:")
//        Text(entry.configuration.favoriteEmoji)
//    }
//}
//
//struct TramDisplayWidget: Widget {
//    let kind: String = "TramDisplayWidget"
//
//    var body: some WidgetConfiguration {
//        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
//            TramDisplayWidgetEntryView(entry: entry)
//                .containerBackground(.fill.tertiary, for: .widget)
//        }
//    }
//}
//
//extension ConfigurationAppIntent {
//    fileprivate static var smiley: ConfigurationAppIntent {
//        let intent = ConfigurationAppIntent()
//        intent.favoriteEmoji = "😀"
//        return intent
//    }
//    
//    fileprivate static var starEyes: ConfigurationAppIntent {
//        let intent = ConfigurationAppIntent()
//        intent.favoriteEmoji = "🤩"
//        return intent
//    }
//}
//
//#Preview(as: .systemSmall) {
//    TramDisplayWidget()
//} timeline: {
//    SimpleEntry(date: .now, configuration: .smiley)
//    SimpleEntry(date: .now, configuration: .starEyes)
//}


import WidgetKit
import SwiftUI
import Foundation

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), departureInfo: "Loading...")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), departureInfo: "Next Tram: 5 mins")
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let userDefaults = UserDefaults(suiteName: "group.com.yourapp")
        let station = userDefaults?.string(forKey: "selectedStation") ?? "Unknown Station"
        let destination = userDefaults?.string(forKey: "selectedDestination") ?? "Unknown Destination"

        fetchNextDeparture(station: station, destination: destination) { departureInfo in
            let entry = SimpleEntry(date: Date(), departureInfo: departureInfo)
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct StationBoardResponse: Codable {
    let stationboard: [Connection]
}

struct Connection: Codable {
    let stop: Stop
}

struct Stop: Codable {
    let departure: Date
}

func fetchNextDeparture(station: String, destination: String, completion: @escaping (String) -> Void) {
    let apiUrl = "https://transport.opendata.ch/v1/stationboard?station=\(station)&limit=5"
    
    guard let url = URL(string: apiUrl) else {
        completion("Invalid URL")
        return
    }

    URLSession.shared.dataTask(with: url) { data, _, error in
        if let data = data, let response = try? JSONDecoder().decode(StationBoardResponse.self, from: data),
           let firstConnection = response.stationboard.first {
            let departureTime = DateFormatter.localizedString(from: firstConnection.stop.departure, dateStyle: .none, timeStyle: .short)
            completion("Dep: \(departureTime)")
        } else {
            completion("No data")
        }
    }.resume()
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let departureInfo: String
}

struct YourWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        Text(entry.departureInfo)
            .font(.headline)
            .padding()
            .containerBackground(.white.gradient, for: .widget)
    }

}

//struct TramDisplayWidget: Widget {
//    let kind: String = "TramDisplayWidget"
//
//    var body: some WidgetConfiguration {
//        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
//            TramDisplayWidgetEntryView(entry: entry)
//                .containerBackground(.fill.tertiary, for: .widget)
//        }
//    }
//}


struct WidgetViewPreviews: PreviewProvider {
  static var previews: some View {
    VStack {
       YourWidgetEntryView(entry: SimpleEntry(date: Date(), departureInfo: "Dep: 12:34"))

    }
    .previewContext(WidgetPreviewContext(family: .systemSmall))

  }
}


@main
struct YourWidget: Widget {
    let kind: String = "YourWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            YourWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Public Transport Widget")
        .description("Shows next departures for your selected station.")
    }
}




//#Preview("Widget Preview") {
//    YourWidgetEntryView(entry: SimpleEntry(date: Date(), departureInfo: "Dep: 12:34"))
//    .previewContext(WidgetPreviewContext(family: .systemSmall))
//}

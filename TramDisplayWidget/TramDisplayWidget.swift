//import WidgetKit
//import SwiftUI
//import Foundation
//
//
//struct Provider: TimelineProvider {
//    func placeholder(in context: Context) -> SimpleEntry {
//        SimpleEntry(date: Date(), departureInfo: "Loading...")
//    }
//
//    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
//        let entry = SimpleEntry(date: Date(), departureInfo: "Next Tram: 5 mins")
//        completion(entry)
//    }
//
//    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
//        let userDefaults = UserDefaults(suiteName: "group.com.yourapp")
//        let station = userDefaults?.string(forKey: "selectedStation") ?? "Unknown Station"
//        let destination = userDefaults?.string(forKey: "selectedDestination") ?? "Unknown Destination"
//
//        fetchNextDeparture(station: station, destination: destination) { departureInfo in
//            let entry = SimpleEntry(date: Date(), departureInfo: departureInfo)
//            let timeline = Timeline(entries: [entry], policy: .atEnd)
//            completion(timeline)
//        }
//    }
//}
//
//struct StationBoardResponse: Codable {
//    let stationboard: [Connection]
//}
//
//struct Connection: Codable {
//    let stop: Stop
//}
//
//struct Stop: Codable {
//    let departure: Date
//}
//
//func fetchNextDeparture(station: String, destination: String, completion: @escaping (String) -> Void) {
//    let apiUrl = "https://transport.opendata.ch/v1/stationboard?station=\(station)&limit=5"
//    
//    guard let url = URL(string: apiUrl) else {
//        completion("Invalid URL")
//        return
//    }
//
//    URLSession.shared.dataTask(with: url) { data, _, error in
//        if let data = data, let response = try? JSONDecoder().decode(StationBoardResponse.self, from: data),
//           let firstConnection = response.stationboard.first {
//            let departureTime = DateFormatter.localizedString(from: firstConnection.stop.departure, dateStyle: .none, timeStyle: .short)
//            completion("Dep: \(departureTime)")
//        } else {
//            completion("No data")
//        }
//    }.resume()
//}
//
//struct SimpleEntry: TimelineEntry {
//    let date: Date
//    let departureInfo: String
//}
//
//struct YourWidgetEntryView: View {
//    var entry: Provider.Entry
//
//    var body: some View {
//        Text(entry.departureInfo)
//            .font(.headline)
//            .padding()
//            .containerBackground(.white.gradient, for: .widget)
//    }
//
//}
//
//
//
//struct WidgetViewPreviews: PreviewProvider {
//  static var previews: some View {
//    VStack {
//       YourWidgetEntryView(entry: SimpleEntry(date: Date(), departureInfo: "Dep: 12:34"))
//
//    }
//    .previewContext(WidgetPreviewContext(family: .systemSmall))
//
//  }
//}
//
//
//@main
//struct YourWidget: Widget {
//    let kind: String = "YourWidget"
//
//    var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: Provider()) { entry in
//            YourWidgetEntryView(entry: entry)
//        }
//        .configurationDisplayName("Public Transport Widget")
//        .description("Shows next departures for your selected station.")
//    }
//}

import WidgetKit
import SwiftUI

struct TransportWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(
            kind: "com.yourapp.transport",
            provider: TransportTimelineProvider()
        ) { entry in
            TransportWidgetView(entry: entry)
        }
        .configurationDisplayName("Next Departures")
        .description("Shows next departures for your selected route")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TransportTimelineEntry: TimelineEntry {
    let date: Date
    let departures: [Departure]
}

struct TransportTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> TransportTimelineEntry {
        TransportTimelineEntry(
            date: Date(),
            departures: [
                Departure(time: Date()),
                Departure(time: Date().addingTimeInterval(900)),
                Departure(time: Date().addingTimeInterval(1800))
            ]
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (TransportTimelineEntry) -> Void) {
        let entry = TransportTimelineEntry(
            date: Date(),
            departures: [
                Departure(time: Date()),
                Departure(time: Date().addingTimeInterval(900)),
                Departure(time: Date().addingTimeInterval(1800))
            ]
        )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<TransportTimelineEntry>) -> Void) {
        let transportService = TransportService()
        
        // Get saved stations from UserDefaults
        let userDefaults = UserDefaults(suiteName: "group.com.yourapp")
        let selectedStation = userDefaults?.string(forKey: "selectedStation") ?? "Zürich, Toni-Areal"
        let selectedDestination = userDefaults?.string(forKey: "selectedDestination") ?? "Zürich, Rathaus"
        
        transportService.fetchDepartures(station: selectedStation, destination: selectedDestination)
        
        // Create timeline entry with the fetched departures
        let entry = TransportTimelineEntry(
            date: Date(),
            departures: transportService.departures
        )
        
        // Update widget every 5 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        
        completion(timeline)
    }
}

struct TransportWidgetView: View {
    var entry: TransportTimelineEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Next Departures")
                .font(.headline)
                .padding(.bottom, 4)
            
            if entry.departures.isEmpty {
                Text("No departures found")
                    .font(.caption)
            } else {
                ForEach(entry.departures.prefix(3)) { departure in
                    Text(departure.time, formatter: timeFormatter)
                        .font(.system(.body, design: .monospaced))
                }
            }
        }
        .padding()
    }
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "de_CH")
        return formatter
    }()
}

@main
struct TransportWidgetBundle: WidgetBundle {
    var body: some Widget {
        TransportWidget()
    }
}

struct WidgetViewPreviews: PreviewProvider {
  static var previews: some View {
    VStack {
       YourWidgetEntryView(entry: SimpleEntry(date: Date(), departureInfo: "Dep: 12:34"))

    }
    .previewContext(WidgetPreviewContext(family: .systemSmall))

  }
}




//this style looks kinda nice:
//struct TransportWidgetEntryView: View {
//    var entry: DepartureProvider.Entry
//
//    var body: some View {
//        VStack(alignment: .leading) {
////            Text("Next Departures").font(.headline)
////            Text(station).font(.headline)
//            Text("Station").font(.headline)
//
////            ForEach(entry.departures.prefix(3), id: \.id) { departure in
////            ForEach(entry.departures.prefix(3).map { $0 }, id: \.id) { departure in
//            ForEach(Array(entry.departures.prefix(3)), id: \.id) { departure in
//                HStack {
//                    Text(departure.number)
//                        .bold()
//                        .frame(width: 30, alignment: .leading)
//
//                    Text(departure.to)
//                        .frame(maxWidth: .infinity, alignment: .leading)
//                    
//                    if let departureDate = iso8601Formatter.date(from: departure.stop.departure) {
//                                           Text(timeFormatter.string(from: departureDate))
//                                               .frame(width: 60, alignment: .trailing)
//                                       } else {
//                                           Text("Unknown")
//                                               .frame(width: 60, alignment: .trailing)
//                                       }
//
//                }
//            }
//        }
//        .padding()
//        .containerBackground(.white.gradient, for: .widget)
//        .background(Color.white) // Ensure there's a background for the widget
//        .cornerRadius(10)
//    }
//}
//





//embedded solution try:
//import WidgetKit
//import SwiftUI
//
//struct Provider: TimelineProvider {
//    func placeholder(in context: Context) -> SimpleEntry {
//        SimpleEntry(date: Date(), content: "Loading...")
//    }
//
//    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
//        let entry = SimpleEntry(date: Date(), content: "Next Tram: 5 mins")
//        completion(entry)
//    }
//
//    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
//        var entries: [SimpleEntry] = []
//        // Fetch data from your web app or API
//        let currentDate = Date()
//        for minuteOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset * 10, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, content: "Next Tram: \(minuteOffset * 10) mins")
//            entries.append(entry)
//        }
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
//    }
//}
//
//struct SimpleEntry: TimelineEntry {
//    let date: Date
//    let content: String
//}
//
//struct YourWidgetEntryView : View {
//    var entry: Provider.Entry
//
//    var body: some View {
//        Text(entry.content)
//    }
//}
//
//@main
//struct YourWidget: Widget {
//    let kind: String = "YourWidget"
//
//    var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: Provider()) { entry in
//            YourWidgetEntryView(entry: entry)
//        }
//        .configurationDisplayName("My Widget")
//        .description("This is an example widget.")
//    }
//}

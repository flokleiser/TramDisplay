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
        print("Widget: getTimeline called")
        
        let userDefaults = UserDefaults(suiteName: "group.TramDisplay.sharedDefaults")
        let station = userDefaults?.string(forKey: "selectedStation") ?? "Unknown Station"
        let destination = userDefaults?.string(forKey: "selectedDestination") ?? "Unknown Destination"
        
        print("Widget: Station: \(station), Destination: \(destination)")


        fetchNextDeparture(station: station, destination: destination) { departureInfo in
            print("Widget: Received departure info: \(departureInfo)")

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
struct YourWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text(entry.departureInfo)
                .font(.headline)
                .foregroundColor(.black) // Explicitly set color
            Text("Updated: \(entry.date, style: .time)") // Add this to verify updates
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure view fills widget
        .containerBackground(.white.gradient, for: .widget)
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


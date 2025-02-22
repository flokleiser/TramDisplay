import WidgetKit
import SwiftUI
import Foundation

import os.log

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), departureTimes: ["Loading..."])

    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), departureTimes: ["Next Tram: 5 mins"])

        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        print("Widget: getTimeline called")
        
        let userDefaults = UserDefaults(suiteName: "group.TramDisplay.sharedDefaults")
        let station = userDefaults?.string(forKey: "selectedStation") ?? "Unknown Station"
        let destination = userDefaults?.string(forKey: "selectedDestination") ?? "Unknown Destination"
        
        print("Widget: Station: \(station), Destination: \(destination)")
        
        print("UserDefaults suite: \(String(describing: userDefaults))")
        print("Selected station: \(station)")
        print("Selected destination: \(destination)")

        fetchNextDeparture(station: station, destination: destination) { departureTimes in
            let entry = SimpleEntry(date: Date(), departureTimes: [departureTimes])

            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
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
        if let data = data, let response = try? JSONDecoder().decode(StationBoardResponse.self, from: data) {
            let departureTimes = response.stationboard.prefix(3).compactMap { connection -> String? in
                if let departureDate = ISO8601DateFormatter().date(from: connection.stop.departure) {
                    return timeFormatter.string(from: departureDate)
                }
                return nil
            }
            let result = departureTimes.isEmpty ? "No data" : departureTimes.joined(separator: "\n")
                  completion(result)
        } else {
            completion("No data")
        }
    }.resume()
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let departureTimes: [String]
}

struct YourWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
                ForEach(entry.departureTimes.prefix(3), id: \.self) { time in
                    HStack {
                        Image(systemName: "tram.fill")
//                            .imageScale(.small)
                            .font(.system(size: 17))
                        Text(time)
                    }
                        .foregroundColor(.white)
                        .font(.system(size: 25, weight: .semibold))
                        .frame(width: 145, height: 35, alignment: .center)

                        .background(Color(red:41/255, green:43/255, blue:47/255))
                        .cornerRadius(10)

                }
                
                Spacer()
                Text("Updated: \(entry.date, style: .time)")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .containerBackground(Color(red: 24/255, green: 27/255, blue: 31/255), for: .widget)
       }
   }


struct WidgetViewPreviews: PreviewProvider {
  static var previews: some View {
    VStack {
        YourWidgetEntryView(entry: SimpleEntry(date: Date(), departureTimes: ["12:34", "12:49", "13:04"]))
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

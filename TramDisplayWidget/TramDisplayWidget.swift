import WidgetKit
import SwiftUI
import Foundation

import os.log


struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
//        SimpleEntry(date: Date(), departureInfo: "Loading...")
        SimpleEntry(date: Date(), departureTimes: ["Loading..."])

    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
//        let entry = SimpleEntry(date: Date(), departureInfo: "Next Tram: 5 mins")
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


//        fetchNextDeparture(station: station, destination: destination) { departureInfo in
        fetchNextDeparture(station: station, destination: destination) { departureTimes in

//            print("Widget: Received departure info: \(departureInfo)")

//            let entry = SimpleEntry(date: Date(), departureInfo: departureInfo)
            let entry = SimpleEntry(date: Date(), departureTimes: [departureTimes])


            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

//struct StationBoardResponse: Codable {
//    let stationboard: [Connection]
//}

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

//    URLSession.shared.dataTask(with: url) { data, _, error in
//        if let data = data, let response = try? JSONDecoder().decode(StationBoardResponse.self, from: data),
//           let firstConnection = response.stationboard.first {
//            
//            if let departureDate = ISO8601DateFormatter().date(from: firstConnection.stop.departure) {
//                          let departureTime = timeFormatter.string(from: departureDate)
//                          completion("Dep: \(departureTime)")
//                      } else {
//                          print("Error: Could not parse departure time")
//                          completion("Error parsing time")
//                      }
//                  } else {
//                      completion("No data")
//                      print("test")
//                      os_log("test",log:.default, type:.debug)
//
//                  }
//              }.resume()
//          }
    URLSession.shared.dataTask(with: url) { data, _, error in
        if let data = data, let response = try? JSONDecoder().decode(StationBoardResponse.self, from: data) {
            let departureTimes = response.stationboard.prefix(3).compactMap { connection -> String? in
                if let departureDate = ISO8601DateFormatter().date(from: connection.stop.departure) {
                    return timeFormatter.string(from: departureDate)
                }
                return nil
            }
            let result = departureTimes.isEmpty ? "No data" : departureTimes.joined(separator: ", ")
                  completion(result)
//            completion(departureTimes.isEmpty ? ["No data"] : departureTimes)
        } else {
            completion("No data")
        }
    }.resume()
}

struct SimpleEntry: TimelineEntry {
    let date: Date
//    let departureInfo: String
    let departureTimes: [String]
}

struct YourWidgetEntryView: View {
    var entry: Provider.Entry

//    var body: some View {
//        VStack {
//            Text(entry.departureInfo)
//                .font(.headline)
//                .foregroundColor(.black) // Explicitly set color
//            Text("Updated: \(entry.date, style: .time)")
//                .font(.caption)
//                .foregroundColor(.gray)
//        }
//        .padding()
//        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure view fills widget
//        .containerBackground(.white.gradient, for: .widget)
//    }
//}
    var body: some View {
//           VStack(alignment: .leading, spacing: 4) {
        VStack {
               ForEach(entry.departureTimes.prefix(3), id: \.self) { time in
//                   Text("Dep: \(time)")
                   Text(time)
                       .foregroundColor(.black) // Explicitly set color
                       .font(.system(size: 25, weight: .semibold))
//                       .font(.headline)
               }

//               Spacer()
               Text("Updated: \(entry.date, style: .time)")
//                   .font(.system(size: 10))
                    .font(.caption)
                   .foregroundColor(.gray)
           }
//           .padding()
//           .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
           .frame(maxWidth: .infinity, maxHeight: .infinity)

           .containerBackground(.white.gradient, for: .widget)
       }
   }




struct WidgetViewPreviews: PreviewProvider {
  static var previews: some View {
    VStack {
//       YourWidgetEntryView(entry: SimpleEntry(date: Date(), departureInfo: "Dep: 12:34"))
//       YourWidgetEntryView(entry: SimpleEntry(date: Date(), departureTimes: "Dep: 12:34"))
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


import WidgetKit
import SwiftUI
import ClockKit


struct ComplicationProvider: TimelineProvider {
    let transportService = TransportService()
    
    func getSnapshot(in context: Context, completion: @escaping (ComplicationEntry) -> Void) {
        let appGroupIdentifier = "group.TramDisplayWatchOs.sharedDefaults"
        let defaults = UserDefaults(suiteName: appGroupIdentifier)!

        let station = defaults.string(forKey: "selectedStation") ?? "Zürich, Toni-Areal"
        let destination = defaults.string(forKey: "selectedDestination") ?? "Zürich, Rathaus"
        
        let entry = ComplicationEntry(
            date: Date(),
            departures: [Departure(time: Date())],
            station: station,
            destination: destination
            )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ComplicationEntry>) -> Void) {
        
        let appGroupIdentifier = "group.TramDisplayWatchOs.sharedDefaults"
        let defaults = UserDefaults(suiteName: appGroupIdentifier)!
        
        let station = defaults.string(forKey: "selectedStation") ?? "Zürich, Toni-Areal"
        let destination = defaults.string(forKey: "selectedDestination") ?? "Zürich, Rathaus"
        
        transportService.fetchDepartures(station: station, destination: destination) { departures in
            let entry = ComplicationEntry(
                date: Date(),
                departures: departures,
                station: station,
                destination: destination
            )
            
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(15*60)))
            completion(timeline)
        }
    }
    
    func placeholder(in context: Context) -> ComplicationEntry {
        ComplicationEntry(
            date: Date(),
            departures: [Departure(time: Date())],
            station: "Zürich, Toni-Areal",
            destination: "Zürich, Rathaus"

        )
    }
}

struct ComplicationEntry: TimelineEntry {
    let date: Date
    let departures: [Departure]
    let station: String
    let destination: String
}

struct ComplicationView: View {
    let entry: ComplicationEntry
    
    @Environment(\.widgetFamily) var family
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "de_CH")
        return formatter
    }()
    
    var body: some View {
        switch family {
        case .accessoryCorner:
            AccessoryCornerView(entry: entry)
        default:
            AccessoryCornerView(entry: entry)
        }
    }
}

struct AccessoryCornerView: View {
    let entry: ComplicationEntry
    
    @State private var layout: Int = 1
    
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "de_CH")
        return formatter
    }()
    
    var body: some View {
          ZStack {
              if layout == 0 {
                  let times = entry.departures.prefix(1).map { timeFormatter.string(from: $0.time) }
                  Text(times.joined(separator: " • "))
                      .font(.system(size: 12))
                      .widgetLabel {
                          Text("Next Tram")
                              .font(.system(size: 10))
                              .foregroundStyle(.white.opacity(0.8))
                      }
                      .widgetCurvesContent()
              } else {
                  Image(systemName: "tram.fill")
                      .resizable()
                      .aspectRatio(contentMode: .fit)
                      .widgetLabel {
                          let times = entry.departures.prefix(3).map { timeFormatter.string(from: $0.time) }
                          Text(times.joined(separator: " • "))

                              .font(.system(size: 12))
                      }
                  //idk why but this breaks the preview
                      .onAppear {
                          layout = defaults.integer(forKey: "complicationLayout")
                      }
              }
          }
          .containerBackground(.clear, for: .widget)
      }
  }
            
    
#Preview(as: .accessoryCorner) {
    TramComplication()
} timeline: {
//    ComplicationEntry(date: Date(), departures: [Departure(time: Date())], station: "Zürich, Toni-Areal", destination: "Zürich, Rathaus")
    ComplicationEntry(date: Date(), departures: [  Departure(time: Date().addingTimeInterval(600)),
                      Departure(time: Date().addingTimeInterval(1200)), // 20 minutes from now
                      Departure(time: Date().addingTimeInterval(1800))   // 30 minutes from now
                  ], station: "Zürich, Toni-Areal", destination: "Zürich, Rathaus")

}

@main
struct TramComplication: Widget {
    private let kind = "com.yourdomain.tramcomplication"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ComplicationProvider()) { entry in
            ComplicationView(entry: entry)
        }
        .configurationDisplayName("Next Tram")
        .description("Shows the next tram departure time")
        .supportedFamilies([
            .accessoryCorner,
        ])
    }
}

import WidgetKit
import SwiftUI
import ClockKit

struct ComplicationProvider: TimelineProvider {
    let transportService = TransportService()
    
    func getSnapshot(in context: Context, completion: @escaping (ComplicationEntry) -> Void) {
        let entry = ComplicationEntry(
            date: Date(),
//            departure: Departure(time: Date()))
            departures: [Departure(time: Date())]
            )
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ComplicationEntry>) -> Void) {
        transportService.fetchDepartures(station: "Zürich, Toni-Areal", destination: "Zürich, Rathaus") { departures in
//            let entries = departures.map { departure in
//                ComplicationEntry(date: Date(), departure: departure)
//            }
            let entry = ComplicationEntry(date: Date(), departures: departures)
            
//            let timeline = Timeline(entries: entries, policy: .after(Date().addingTimeInterval(15 * 60)))
//            completion(timeline)
            let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(15*60)))
            completion(timeline)
        }
    }
    
    func placeholder(in context: Context) -> ComplicationEntry {
        ComplicationEntry(
            date: Date(),
//            departure: Departure(time: Date())
            departures: [Departure(time: Date())]
        )
    }
}

struct ComplicationEntry: TimelineEntry {
    let date: Date
//    let departure: Departure
    let departures: [Departure]
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
//        case .accessoryCircular:
//            AccessoryCircularView(entry: entry)
        case .accessoryCorner:
            AccessoryCornerView(entry: entry)
//        case .accessoryRectangular:
//            AccessoryRectangularView(entry: entry)
        default:
            AccessoryCornerView(entry: entry)
        }
    }
}

//struct AccessoryCircularView: View {
//    let entry: ComplicationEntry
//    
//    private let timeFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.timeStyle = .short
//        formatter.locale = Locale(identifier: "de_CH")
//        return formatter
//    }()
//    
//    var body: some View {
//        VStack {
//            Image(systemName: "tram.fill")
//            Text(timeFormatter.string(from: entry.departure.time))
//                .font(.caption2)
//        }
//        .containerBackground(Color(red: 24/255, green: 27/255, blue: 31/255), for: .widget)
//
//    }
//}

struct AccessoryCornerView: View {
    let entry: ComplicationEntry
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "de_CH")
        return formatter
    }()

//    var body: some View {
//        ZStack {
//            AccessoryWidgetBackground()
//            Image(systemName: "tram.fill")
//                .imageScale(.small)
//                .font(.caption2)
//                .frame(width: 10, height: 10)
//                .widgetCurvesContent()
//            
//                .widgetLabel {
////                    Text(timeFormatter.string(from: entry.departure.time))
////                    .font(.caption)
//                    HStack(spacing: 2) {
//                        Text(timeFormatter.string(from: entry.departure.time))
//                        Text("•")
//                        .foregroundStyle(.secondary)
//                        Text(timeFormatter.string(from: entry.departure.time.addingTimeInterval(10 * 60)))
//                        Text("•")
//                        .foregroundStyle(.secondary)
//                        Text(timeFormatter.string(from: entry.departure.time.addingTimeInterval(20 * 60)))
//                    }
//                    .font(.caption2)
//                }
////                .containerBackground(.white.gradient, for: .widget)
//                  .containerBackground(.clear, for: .widget)
//            
//        }
//    }
    
    var body: some View {
        ZStack {
//            Image(systemName: "tram.fill")
            let times = entry.departures.prefix(1).map { timeFormatter.string(from: $0.time) }
            Text(times.joined(separator: " • "))
                    .font(.system(size: 12))


                .widgetLabel {
//                    Text("\(timeFormatter.string(from: entry.departure.time)) • \(timeFormatter.string(from: entry.departure.time.addingTimeInterval(10 * 60))) • \(timeFormatter.string(from: entry.departure.time.addingTimeInterval(20 * 60)))")
                Text("Next Tram")
                        .font(.system(size: 2))
//                        .font(.caption)
                 }
        }
                .widgetCurvesContent()
                .containerBackground(.clear, for: .widget)
        }

}
    
    
// -kinda working
//    var body: some View {
//           Image(systemName: "tram.fill")
//               .imageScale(.small)
//               .font(.system(size: 12))
//               .widgetCurvesContent()
//               .widgetLabel {
//                   let times = entry.departures.prefix(3).map { timeFormatter.string(from: $0.time) }
//                   Text(times.joined(separator: " • "))
//                       .font(.system(size: 12))
//               }
//               .containerBackground(.clear, for: .widget)
//       }
//   }


//struct AccessoryRectangularView: View {
//    let entry: ComplicationEntry
//    
//    private let timeFormatter: DateFormatter = {
//        let formatter = DateFormatter()
//        formatter.timeStyle = .short
//        formatter.locale = Locale(identifier: "de_CH")
//        return formatter
//    }()
//    
//    var body: some View {
//        HStack {
//            Image(systemName: "tram.fill")
//            VStack(alignment: .leading) {
//                Text("Next departure")
//                    .font(.caption2)
//                Text(timeFormatter.string(from: entry.departure.time))
//                    .font(.caption)
//            }
//        }
//        .containerBackground(Color(red: 24/255, green: 27/255, blue: 31/255), for: .widget)
//
//    }
//}

//#Preview(as: .accessoryCircular) {
//    TramComplication()
//} timeline: {
//    ComplicationEntry(date: Date(), departure: Departure(time: Date()))
//    ComplicationEntry(date: Date().addingTimeInterval(3600), departure: Departure(time: Date().addingTimeInterval(3600)))
//}
//
//#Preview(as: .accessoryRectangular) {
//    TramComplication()
//} timeline: {
//    ComplicationEntry(date: Date(), departure: Departure(time: Date()))
//}

#Preview(as: .accessoryCorner) {
    TramComplication()
} timeline: {
//    ComplicationEntry(date: Date(), departure: Departure(time: Date()))
    ComplicationEntry(date: Date(), departures: [Departure(time: Date())])

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
            .accessoryCircular,
            .accessoryCorner,
            .accessoryRectangular
        ])
    }
}

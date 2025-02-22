import WidgetKit
import SwiftUI
import ClockKit

struct ComplicationProvider: TimelineProvider {
    let transportService = TransportService()
    
    func getSnapshot(in context: Context, completion: @escaping (ComplicationEntry) -> Void) {
        let entry = ComplicationEntry(date: Date(), departure: Departure(time: Date()))
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<ComplicationEntry>) -> Void) {
        transportService.fetchDepartures(station: "Zürich, Toni-Areal", destination: "Zürich, Rathaus") { departures in
            let entries = departures.map { departure in
                ComplicationEntry(date: Date(), departure: departure)
            }
            
            let timeline = Timeline(entries: entries, policy: .after(Date().addingTimeInterval(15 * 60)))
            completion(timeline)
        }
    }
    
    func placeholder(in context: Context) -> ComplicationEntry {
        ComplicationEntry(date: Date(), departure: Departure(time: Date()))
    }
}

struct ComplicationEntry: TimelineEntry {
    let date: Date
    let departure: Departure
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
        case .accessoryCircular:
            AccessoryCircularView(entry: entry)
        case .accessoryCorner:
            AccessoryCornerView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        default:
            AccessoryCircularView(entry: entry)
        }
    }
}

struct AccessoryCircularView: View {
    let entry: ComplicationEntry
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "de_CH")
        return formatter
    }()
    
    var body: some View {
        VStack {
            Image(systemName: "tram.fill")
            Text(timeFormatter.string(from: entry.departure.time))
                .font(.caption2)
        }
        .containerBackground(Color(red: 24/255, green: 27/255, blue: 31/255), for: .widget)

    }
}

struct AccessoryCornerView: View {
    let entry: ComplicationEntry
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "de_CH")
        return formatter
    }()
    
    var body: some View {
        VStack {
            Text("Next")
                .font(.caption2)
            Text(timeFormatter.string(from: entry.departure.time))
                .font(.caption)
        }
        .containerBackground(Color(red: 24/255, green: 27/255, blue: 31/255), for: .widget)

    }
    
}

struct AccessoryRectangularView: View {
    let entry: ComplicationEntry
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "de_CH")
        return formatter
    }()
    
    var body: some View {
        HStack {
            Image(systemName: "tram.fill")
            VStack(alignment: .leading) {
                Text("Next departure")
                    .font(.caption2)
                Text(timeFormatter.string(from: entry.departure.time))
                    .font(.caption)
            }
        }
        .containerBackground(Color(red: 24/255, green: 27/255, blue: 31/255), for: .widget)

    }
}

#Preview(as: .accessoryCircular) {
    TramComplication()
} timeline: {
    ComplicationEntry(date: Date(), departure: Departure(time: Date()))
    ComplicationEntry(date: Date().addingTimeInterval(3600), departure: Departure(time: Date().addingTimeInterval(3600)))
}

#Preview(as: .accessoryRectangular) {
    TramComplication()
} timeline: {
    ComplicationEntry(date: Date(), departure: Departure(time: Date()))
}

#Preview(as: .accessoryCorner) {
    TramComplication()
} timeline: {
    ComplicationEntry(date: Date(), departure: Departure(time: Date()))
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

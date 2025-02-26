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

    
    var body: some View {
        switch family {
        case .accessoryCorner:
            AccessoryCornerView(entry: entry)
        case .accessoryCircular:
            AccessoryCircularView(entry: entry)
        case .accessoryRectangular:
            AccessoryRectangularView(entry: entry)
        case .accessoryInline:
            AccessoryInlineView(entry: entry)

        default:
            AccessoryCornerView(entry: entry)
        }
    }
}



struct AccessoryCornerView: View {
    let entry: ComplicationEntry
    
    
    //uncomment this before run
//    var layout: Int {
//         let appGroupIdentifier = "group.TramDisplayWatchOs.sharedDefaults"
//         let defaults = UserDefaults(suiteName: appGroupIdentifier)!
//         return defaults.integer(forKey: "complicationLayout")
//     }
    
    var layout: Int = 3

    
    var body: some View {
        
            ZStack {
                if layout == 0 {
                    let times = entry.departures.prefix(1).map { timeFormatter.string(from: $0.time) }
                    Text(times.joined(separator: " • "))
                        .font(.system(size: 12))
                        .widgetLabel {
                            
                            Text("From \(entry.station.replacingOccurrences(of: "Zürich, ", with: ""))")
                                .font(.system(size: 10))
                                .foregroundStyle(.white.opacity(0.8))
                        }
                        .widgetCurvesContent()
                } else if layout == 1 {
                    Image(systemName: "tram.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .widgetLabel {
                            let times = entry.departures.prefix(3).map { timeFormatter.string(from: $0.time) }
                            Text(times.joined(separator: " • "))
                            
                                .font(.system(size: 12))
                        }
                }
                else {
                    if let nextDeparture = entry.departures.first {
                        
                        let currentTime = Date()
                        let departureTime = nextDeparture.time
                        let nextIndex = 1
                        
                        if entry.departures.indices.contains(nextIndex) {
                                let nextDepartureTime = entry.departures[nextIndex].time
                                let tramFrequency = nextDepartureTime.timeIntervalSince(departureTime) / 60
                                
                                let timeUntilNextTram = departureTime.timeIntervalSince(currentTime) / 60
                                let progress = 1.0 - (timeUntilNextTram / tramFrequency)
                                let clampedProgress = min(max(progress, 0.0), 1.0)
                        
                        Text("\(Int(ceil(timeUntilNextTram)))m")
                                .widgetCurvesContent()
                                .font(.system(size: 10, weight: .medium))
                            .widgetLabel {
                                Gauge(value: clampedProgress, in: 0...1) {

//                                    VStack(spacing: 2) {
////                                        Text("\(Int(ceil(timeUntilNextTram))) mins")
//                                        Text("test")
//                                            .font(.system(size: 14, weight: .medium))
//                                        
//                                        Text(timeFormatter.string(from: departureTime))
//                                            .font(.system(size: 10))
//                                            .foregroundStyle(.white.opacity(0.8))
//                                    }
                                }
                            }
                        }
                    } else {
                        Text("No departures")
                            .containerBackground(.clear, for: .widget)
                    }
                        

               }
        }
            .containerBackground(.clear, for: .widget)

    }
  }

struct AccessoryRectangularView: View {
    let entry: ComplicationEntry
    
    var layout: Int {
         let appGroupIdentifier = "group.TramDisplayWatchOs.sharedDefaults"
         let defaults = UserDefaults(suiteName: appGroupIdentifier)!
         return defaults.integer(forKey: "complicationLayout")
     }
    
    var body: some View {
          ZStack {
              if layout == 0 {
                  let times = entry.departures.prefix(1).map { timeFormatter.string(from: $0.time) }
                      Text(times.joined(separator: " • "))
                          .font(.system(size: 12))
                      .widgetLabel {
                        
                        Text("From \(entry.station.replacingOccurrences(of: "Zürich, ", with: ""))")
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
              }
          }
          .containerBackground(.clear, for: .widget)
      }
  }

struct AccessoryInlineView: View {
    let entry: ComplicationEntry
    
    var layout: Int {
         let appGroupIdentifier = "group.TramDisplayWatchOs.sharedDefaults"
         let defaults = UserDefaults(suiteName: appGroupIdentifier)!
         return defaults.integer(forKey: "complicationLayout")
     }
    
    var body: some View {
          ZStack {
                  let times = entry.departures.prefix(3).map { timeFormatter.string(from: $0.time) }
//                      Text(times.joined(separator: " • "))
                      Text(times.joined(separator: " | "))

                          .font(.system(size: 12))
                      .widgetLabel {
                        
                        Text("From \(entry.station.replacingOccurrences(of: "Zürich, ", with: ""))")
                              .font(.system(size: 10))
                              .foregroundStyle(.white.opacity(0.8))
                      }
                      .widgetCurvesContent()
          }
          .containerBackground(.clear, for: .widget)
      }
  }

struct AccessoryCircularView: View {
    let entry: ComplicationEntry
    
    var layout: Int {
         let appGroupIdentifier = "group.TramDisplayWatchOs.sharedDefaults"
         let defaults = UserDefaults(suiteName: appGroupIdentifier)!
         return defaults.integer(forKey: "complicationLayout")
     }
    
    var body: some View {
        if let nextDeparture = entry.departures.first {
            
            let currentTime = Date()
            let departureTime = nextDeparture.time
            let nextIndex = 1
            
            if entry.departures.indices.contains(nextIndex) {
                let nextDepartureTime = entry.departures[nextIndex].time
                let tramFrequency = nextDepartureTime.timeIntervalSince(departureTime) / 60
                
                let timeUntilNextTram = departureTime.timeIntervalSince(currentTime) / 60
                let progress = 1.0 - (timeUntilNextTram / tramFrequency)
                let clampedProgress = min(max(progress, 0.0), 1.0)
                
                //
                Gauge(value: clampedProgress, in: 0...1) {
                    VStack(spacing: 2) {
                        Text("\(Int(ceil(timeUntilNextTram)))m")
                            .font(.system(size: 14, weight: .medium))
                        
                        Text(timeFormatter.string(from: departureTime))
                            .font(.system(size: 10))
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
                .gaugeStyle(.accessoryCircular)
                .tint(.green)
                .widgetLabel {
                    Text("\(Int(ceil(timeUntilNextTram)))m")
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                }
                .containerBackground(.clear, for: .widget)
            }

           } else {
               Text("--")
                   .font(.system(size: 12))
                   .widgetLabel {
                       Text("From \(entry.station.replacingOccurrences(of: "Zürich, ", with: ""))")
                           .font(.system(size: 10))
                           .foregroundStyle(.white.opacity(0.8))
                   }
                   .containerBackground(.clear, for: .widget)
           }
       }
   }
    

//previews
#Preview(as: .accessoryCorner) {
    TramComplication()
} timeline: {
    ComplicationEntry(date: Date(), departures: [  Departure(time: Date().addingTimeInterval(600)),
                      Departure(time: Date().addingTimeInterval(1200)), // 20 minutes from now
                      Departure(time: Date().addingTimeInterval(1800))   // 30 minutes from now
                  ], station: "Zürich, Toni-Areal", destination: "Zürich, Rathaus")
}


#Preview(as: .accessoryRectangular) {
    TramComplication()
} timeline: {
    ComplicationEntry(date: Date(), departures: [  Departure(time: Date().addingTimeInterval(600)),
                      Departure(time: Date().addingTimeInterval(1200)), // 20 minutes from now
                      Departure(time: Date().addingTimeInterval(1800))   // 30 minutes from now
                  ], station: "Zürich, Toni-Areal", destination: "Zürich, Rathaus")

}

#Preview(as: .accessoryInline) {
    TramComplication()
} timeline: {
    ComplicationEntry(date: Date(), departures: [  Departure(time: Date().addingTimeInterval(600)),
                      Departure(time: Date().addingTimeInterval(1200)), // 20 minutes from now
                      Departure(time: Date().addingTimeInterval(1800))   // 30 minutes from now
                  ], station: "Zürich, Toni-Areal", destination: "Zürich, Rathaus")

}

#Preview(as: .accessoryCircular) {
    TramComplication()
} timeline: {
    ComplicationEntry(date: Date(), departures: [  Departure(time: Date().addingTimeInterval(600)),
                      Departure(time: Date().addingTimeInterval(1200)), // 20 minutes from now
                      Departure(time: Date().addingTimeInterval(1800))   // 30 minutes from now
                  ], station: "Zürich, Toni-Areal", destination: "Zürich, Rathaus")

}


class ExtensionDelegate: NSObject, WKExtensionDelegate {
    func handle(_ backgroundTasks: Set<WKRefreshBackgroundTask>) {
        for task in backgroundTasks {
            if task is WKApplicationRefreshBackgroundTask {
                let complicationServer = CLKComplicationServer.sharedInstance()
                for complication in complicationServer.activeComplications ?? [] {
                    complicationServer.reloadTimeline(for: complication)
                }
            }
            task.setTaskCompletedWithSnapshot(false)
        }
    }
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
            .accessoryCircular,
            .accessoryInline,
            .accessoryRectangular
        ])
    }
}

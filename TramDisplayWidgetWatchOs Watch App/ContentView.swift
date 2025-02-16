import SwiftUI
import WatchKit
import ClockKit

// MARK: - Models
struct Departure: Identifiable, Codable {
    let id = UUID()
    let time: Date
    
    enum CodingKeys: String, CodingKey {
        case time
    }
}

struct StationBoardResponse: Codable {
    let stationboard: [Connection]
    
    struct Connection: Codable {
        let stop: Stop
        let passList: [PassList]?
        
        struct Stop: Codable {
            let departure: String
        }
        
        struct PassList: Codable {
            let station: Station
            let departure: String?
            
            struct Station: Codable {
                let name: String?
            }
        }
    }
}

class TransportService: ObservableObject {
    @Published var departures: [Departure] = []
    @Published var isLoading = false
    @Published var crownValue: Double = 0
    
    func fetchDepartures(station: String, destination: String) {
        isLoading = true
        let apiURL = "https://transport.opendata.ch/v1/stationboard?station=\(station.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? station)&limit=10"
        
        guard let url = URL(string: apiURL) else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    print("Error fetching data: \(error)")
                    WKInterfaceDevice.current().play(.failure)
                    return
                }
                
                guard let data = data else { return }
                
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    
                    let response = try decoder.decode(StationBoardResponse.self, from: data)
                    let filteredDepartures = response.stationboard
                        .filter { connection in
                            connection.passList?.contains { pass in
                                pass.station.name == destination
                            } ?? false
                        }
                        .compactMap { connection -> Departure? in
                            if let date = ISO8601DateFormatter().date(from: connection.stop.departure) {
                                return Departure(time: date)
                            }
                            return nil
                        }
                        .prefix(3)
                    
                    self.departures = Array(filteredDepartures)
                    
                    //haptic feedback, annoying sound tho
//                    if !self.departures.isEmpty {
//                        WKInterfaceDevice.current().play(.success)
//                    }
                    
                } catch {
                    print("Error decoding JSON: \(error)")
                    WKInterfaceDevice.current().play(.failure)
                }
            }
        }.resume()
    }
}

// MARK: -contentview
struct ContentView: View {
    @State private var selectedStation: String = "Zürich, Toni-Areal"
    @State private var selectedDestination: String = "Zürich, Rathaus"
    @StateObject private var transportService = TransportService()
    
    let stations = ["Zürich, Rathaus", "Zürich, Toni-Areal"]
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "de_CH")
        return formatter
    }()
    
    var body: some View {
        List {
            Section(header: Text("Stations")) {
                Picker("From", selection: $selectedStation) {
                    ForEach(stations, id: \.self) { station in
                        Text(station).tag(station)
                    }
                }
                
                Picker("To", selection: $selectedDestination) {
                    ForEach(stations, id: \.self) { station in
                        Text(station).tag(station)
                    }
                }
            }
            
            Section(header: Text("Next Departures")) {
                if transportService.isLoading {
                    ProgressView()
                } else if transportService.departures.isEmpty {
                    Text("No departures found")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(transportService.departures) { departure in
                        Text("\(departure.time, formatter: timeFormatter)")
                    }
                }
            }
        }
        .onChange(of: selectedStation) { oldValue, newValue in
                    transportService.fetchDepartures(station: newValue, destination: selectedDestination)
                }
                .onChange(of: selectedDestination) { oldValue, newValue in
                    transportService.fetchDepartures(station: selectedStation, destination: newValue)
                }
                .onAppear {
                    transportService.fetchDepartures(station: selectedStation, destination: selectedDestination)
                }
                .focusable()
                .digitalCrownRotation(detent: $transportService.crownValue, from: 0, through: 1, by: 0.1, sensitivity: .medium, isContinuous: false, isHapticFeedbackEnabled: true) { _ in
                    transportService.fetchDepartures(station: selectedStation, destination: selectedDestination)
                }
       
    }
}

// MARK: -apple watch face complication thingy
class ComplicationController: NSObject, CLKComplicationDataSource {
    private let transportService = TransportService()
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        transportService.fetchDepartures(station: "Zürich, Toni-Areal", destination: "Zürich, Rathaus")
        
        switch complication.family {
        case .modularSmall:
            let template = CLKComplicationTemplateModularSmallStackText(
                line1TextProvider: CLKSimpleTextProvider(text: "Next"),
                line2TextProvider: CLKSimpleTextProvider(text: "--:--")
            )
            
            if let nextDeparture = transportService.departures.first {
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                template.line2TextProvider = CLKSimpleTextProvider(text: formatter.string(from: nextDeparture.time))
            }
            
            let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
            handler(entry)
            
        default:
            handler(nil)
        }
    }
    
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    func getTimelineStartDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(Date())
    }
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        handler(Date().addingTimeInterval(3600)) // 1 hour from now
    }
}


#Preview {
    ContentView()
}

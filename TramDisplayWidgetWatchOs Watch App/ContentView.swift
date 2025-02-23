import SwiftUI
import WatchKit
import ClockKit
import Foundation
import WidgetKit

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
                    
                } catch {
                    print("Error decoding JSON: \(error)")
                    WKInterfaceDevice.current().play(.failure)
                }
            }
        }.resume()
    }
}

extension TransportService {
    func fetchDepartures(station: String, destination: String, completion: @escaping ([Departure]) -> Void) {
        let apiURL = "https://transport.opendata.ch/v1/stationboard?station=\(station.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? station)&limit=10"
        
        guard let url = URL(string: apiURL) else {
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                completion([])
                return
            }
            
            guard let data = data else {
                completion([])
                return
            }
            
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
                
                completion(Array(filteredDepartures))
                
            } catch {
                print("Error decoding JSON: \(error)")
                completion([])
            }
        }.resume()
    }
}

let appGroupIdentifier = "group.TramDisplayWatchOs.sharedDefaults"
let defaults = UserDefaults(suiteName: appGroupIdentifier)!

struct ContentView: View {
//    @State private var selectedStation: String = "Zürich, Toni-Areal"
//    @State private var selectedDestination: String = "Zürich, Rathaus"
    @StateObject private var transportService = TransportService()
    
    @State private var selectedStation: String = UserDefaults(suiteName: appGroupIdentifier)?.string(forKey: "selectedStation") ?? "Zürich, Toni-Areal"
    @State private var selectedDestination: String = UserDefaults(suiteName: appGroupIdentifier)?.string(forKey: "selectedDestination") ?? "Zürich, Rathaus"


//    @AppStorage("complicationLayout") private var layout: Int = 0
    @State private var layout: Int = UserDefaults(suiteName: appGroupIdentifier)?.integer(forKey: "complicationLayout") ?? 0


    
    let stations = ["Zürich, Rathaus", "Zürich, Toni-Areal"]
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "de_CH")
        return formatter
    }()
    
    var body: some View {
        List {
            Section(header:
                        HStack() {
                
                Image(systemName: "tram.fill")
                Text("Next Departures").font(.headline)
            }
                .padding(.top, -19.0)
                .frame(height: 0.0)
            ) {
                
                if transportService.isLoading {
                    ProgressView()
                } else if transportService.departures.isEmpty {
                    Text("No departures found")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(transportService.departures) { departure in
                        Text("\(departure.time, formatter: timeFormatter)")
                            .frame(height: 8)
                    }
                }
            }
            
            Section(header: HStack() {Image(systemName: "house.and.flag.fill")
                Text("Stations").font(.headline)
            }
            ) {
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
            
//            Section(header: HStack() {Image(systemName: "gear")
//                Text("Settings").font(.headline)
//            } {

            Section(header: Text("Settings").font(.headline)) {
                          VStack(alignment: .leading, spacing: 10) {
//                              Text("Complication Layout")
//                                  .font(.subheadline)
//                                  .bold()
                              
                              Picker("Layout", selection: $layout) {
                                  Text("Time Outer").tag(0)
                                  Text("Time Inner").tag(1)
                              }
//                              .background(Color.gray.opacity(0.2))
                              .cornerRadius(8)
                              .onChange(of: layout) {oldValue, newValue in
                                  defaults.set(newValue, forKey: "complicationLayout")
                                  WidgetCenter.shared.reloadAllTimelines()
                              }
                      
                          }
                          .padding(.vertical, 6)
                      }
                  }
        
//            .onChange(of: layout) { oldValue, newValue in
//                WidgetCenter.shared.reloadAllTimelines()
////                UserDefaults.standard.set(newValue, forKey: "layout")
//            }
            
            .onChange(of: selectedStation) { oldValue, newValue in
                defaults.set(newValue, forKey: "selectedStation")
                defaults.synchronize()
                transportService.fetchDepartures(station: newValue, destination: selectedDestination)
                WidgetCenter.shared.reloadAllTimelines()
            }
            .onChange(of: selectedDestination) { oldValue, newValue in
                defaults.set(newValue, forKey: "selectedDestination")
                defaults.synchronize()

                transportService.fetchDepartures(station: selectedStation, destination: newValue)
                WidgetCenter.shared.reloadAllTimelines()
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

//struct SettingsView: View {
//    @AppStorage("complicationLayout") private var layout: Int = 1
//    
//    var body: some View {
//        Form {
//            Picker("Layout", selection: $layout) {
//                Text("Time Outer").tag(0)
//                Text("Time Inner").tag(1)
//            }
////            .pickerStyle(.segmented)
////            .pickerStyle(SegmentedPickerStyle())
//            
//        }
//    }
//}

#Preview {
    ContentView()
//    SettingsView()
}


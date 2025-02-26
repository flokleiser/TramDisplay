import SwiftUI
import WatchKit
import ClockKit
import Foundation
import WidgetKit

let appGroupIdentifier = "group.TramDisplayWatchOs.sharedDefaults"
let defaults = UserDefaults(suiteName: appGroupIdentifier)!

struct ContentView: View {
    
    @StateObject private var transportService = TransportService()
    @State private var selectedStation: String = UserDefaults(suiteName: appGroupIdentifier)?.string(forKey: "selectedStation") ?? "Zürich, Toni-Areal"
    @State private var selectedDestination: String = UserDefaults(suiteName: appGroupIdentifier)?.string(forKey: "selectedDestination") ?? "Zürich, Rathaus"

    @State private var layout: Int = UserDefaults(suiteName: appGroupIdentifier)?.integer(forKey: "complicationLayout") ?? 0

    let stations = ["Zürich, Rathaus", "Zürich, Toni-Areal"]
    
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
                Button("Reload") {
                    WidgetCenter.shared.reloadAllTimelines()
                    print("test")
                }
            }
            

            Section(header: HStack() {
                Image(systemName: "gearshape")
                Text("Settings").font(.headline)
            }
            )
            {
                    
                          VStack(alignment: .leading, spacing: 10) {
                              
                              Picker("Layout", selection: $layout) {
                                  Text("One Departure").tag(0)
                                  Text("Three Departures").tag(1)
                                  Text("Time Until").tag(2)

                              }
                              .cornerRadius(8)
                              .onChange(of: layout) {oldValue, newValue in
                                  defaults.set(newValue, forKey: "complicationLayout")
                                  WidgetCenter.shared.reloadAllTimelines()
                              }
                      
                          }
                          .padding(.vertical, 6)
                      }
                  }
        
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

#Preview {
    ContentView()
}

@main
struct TramDisplayWidgetWatchOs_Watch_AppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
//            SettingsView()
        }
    }
}


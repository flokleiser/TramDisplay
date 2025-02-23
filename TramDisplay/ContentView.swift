import SwiftUI
import WebKit
import Foundation
import WidgetKit

let appGroupIdentifier = "group.TramDisplay.sharedDefaults"
let defaults = UserDefaults(suiteName: appGroupIdentifier)!


struct ContentView: View {
//    @AppStorage("selectedStation") private var selectedStation: String = "Zürich, Toni-Areal"
//    @AppStorage("selectedDestination") private var selectedDestination: String = "Zürich, Rathaus"
    
    @State private var selectedStation: String = UserDefaults(suiteName: appGroupIdentifier)?.string(forKey: "selectedStation") ?? "Zürich, Toni-Areal"
    @State private var selectedDestination: String = UserDefaults(suiteName: appGroupIdentifier)?.string(forKey: "selectedDestination") ?? "Zürich, Rathaus"

    
    let stations = ["Zürich, Rathaus", "Zürich, Toni-Areal"]
    
    @StateObject private var transportService = TransportService()
       
       var body: some View {
           VStack {
               Text("Select Station & Destination").font(.headline)
                   .padding()
               
               Picker("Station", selection: $selectedStation) {
                   ForEach(stations, id: \.self) { station in
                       Text(station)
                   }
               }
               .pickerStyle(MenuPickerStyle())
               
               
               Picker("Destination", selection: $selectedDestination) {
                   ForEach(stations, id: \.self) { station in
                       Text(station)
                   }
               }
               .pickerStyle(MenuPickerStyle())
               
               .padding()
               
               Button("Save Selection") {
                   defaults.set(selectedStation, forKey: "selectedStation")
                   defaults.set(selectedDestination, forKey: "selectedDestination")
                   defaults.synchronize()


//                   UserDefaults(suiteName: "group.TramDisplay.sharedDefaults")?.set(selectedStation, forKey: "selectedStation")
//                   UserDefaults(suiteName: "group.TramDisplay.sharedDefaults")?.set(selectedDestination, forKey: "selectedDestination")
//                   UserDefaults.synchronize()
                   WidgetCenter.shared.reloadAllTimelines()


                   
//                       .onChange(of: selectedStation) { oldValue, newValue in
//                           defaults.set(newValue, forKey: "selectedStation")
//                           defaults.synchronize()
//                           transportService.fetchDepartures(station: newValue, destination: selectedDestination)
//                           WidgetCenter.shared.reloadAllTimelines()
//                       }
//                       .onChange(of: selectedDestination) { oldValue, newValue in
//                           defaults.set(newValue, forKey: "selectedDestination")
//                           defaults.synchronize()
//
//                           transportService.fetchDepartures(station: selectedStation, destination: newValue)
//                           WidgetCenter.shared.reloadAllTimelines()
//                       }

                   transportService.fetchDepartures(station: selectedStation, destination: selectedDestination)
               }
               
               Divider().padding()
               
               Text("Next Departures").font(.headline)
               
               if transportService.departures.isEmpty {
                   Text("No departures found.")
               } else {
                   ForEach(transportService.departures) { departure in
                       Text("\(departure.time, formatter: timeFormatter)")
                           .padding(5)
                   }
               }
           }
           .onAppear {
               transportService.fetchDepartures(station: selectedStation, destination: selectedDestination )
           }
       }
   }

#Preview {
    ContentView()
}

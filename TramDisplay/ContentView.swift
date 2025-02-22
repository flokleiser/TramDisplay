import SwiftUI
import WebKit
import Foundation

struct ContentView: View {
    @AppStorage("selectedStation") private var selectedStation: String = "Zürich, Toni-Areal"
    @AppStorage("selectedDestination") private var selectedDestination: String = "Zürich, Rathaus"
    
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
                   UserDefaults(suiteName: "group.TramDisplay.sharedDefaults")?.set(selectedStation, forKey: "selectedStation")
                   UserDefaults(suiteName: "group.TramDisplay.sharedDefaults")?.set(selectedDestination, forKey: "selectedDestination")
                   

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
               transportService.fetchDepartures(station: selectedStation, destination: selectedDestination)
           }
       }
   }

#Preview {
    ContentView()
}
import SwiftUI
import WebKit

struct ContentView: View {
    @AppStorage("selectedStation") private var selectedStation: String = "Zürich, Toni-Areal"
    @AppStorage("selectedDestination") private var selectedDestination: String = "Zürich, Rathaus"
    
    let stations = ["Zürich, Rathaus", "Zürich, Toni-Areal", "Zürich, HB", "Zürich, Stadelhofen"]
    
    var body: some View {
        VStack {
            Text("Select Station & Destination").font(.headline)
            
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
            
            Button("Save Selection") {
                UserDefaults(suiteName: "group.com.yourapp")?.set(selectedStation, forKey: "selectedStation")
                UserDefaults(suiteName: "group.com.yourapp")?.set(selectedDestination, forKey: "selectedDestination")
            }
            .padding()
        }
    }
}
    

#Preview {
    ContentView()
//    ViewController()
}

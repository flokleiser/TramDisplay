import SwiftUI
import WebKit
import Foundation

struct WebView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false
        webView.contentMode = .scaleAspectFit
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
    }
}

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
//               .onChange(of: selectedStation) {
//                   transportService.fetchDepartures(station: selectedStation, destination: selectedDestination)
//               }
               
               
               Picker("Destination", selection: $selectedDestination) {
                   ForEach(stations, id: \.self) { station in
                       Text(station)
                   }
               }
               .pickerStyle(MenuPickerStyle())
//               .onChange(of: selectedDestination) {
//                   transportService.fetchDepartures(station: selectedStation, destination: selectedDestination)
//
//               }
               
               .padding()
               
               Button("Save Selection") {
                   UserDefaults(suiteName: "group.com.yourapp")?.set(selectedStation, forKey: "selectedStation")
                   UserDefaults(suiteName: "group.com.yourapp")?.set(selectedDestination, forKey: "selectedDestination")
                   
//                   print(selectedStation,selectedDestination)

                   transportService.fetchDepartures(station: selectedStation, destination: selectedDestination)

               }
//               .onSubmit {
//                   print("test")
//                   transportService.fetchDepartures(station: selectedStation, destination: selectedDestination)
//               }
               
               
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
//               Divider().padding()
               
//               Text("Web Preview").font(.headline)

//               WebView(urlString: "https://flokleiser.github.io/TransportAPITest/")
//                   .frame(height: 250)
//                   .ignoresSafeArea()
           }
           .onAppear {
               transportService.fetchDepartures(station: selectedStation, destination: selectedDestination)
           }
       }
   }

private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    return formatter
}()

struct Departure: Codable, Identifiable {
    let id = UUID()
    let time: Date
    
    enum CodingKeys: String, CodingKey {
           case time
       }

       init(time: Date) {
           self.time = time
       }

       init(from decoder: Decoder) throws {
           let container = try decoder.container(keyedBy: CodingKeys.self)
           self.time = try container.decode(Date.self, forKey: .time)
       }
}

struct StationBoardResponse: Codable {
    struct StationboardEntry: Codable {
        struct Stop: Codable {
            let departure: String
        }
        let stop: Stop
    }
    let stationboard: [StationboardEntry]
}
//struct StationBoardResponse: Codable {
//    struct StationboardEntry: Codable {
//        struct PassListEntry: Codable {
//            let departure: String?
//            let station: Station
//            
//            struct Station: Codable {
//                let name: String?
//            }
//        }
//        let passList: [PassListEntry]
//    }
//    let stationboard: [StationboardEntry]
//}


class TransportService: ObservableObject {
    @Published var departures: [Departure] = []
    
    func fetchDepartures(station: String, destination: String) {
//    func fetchDepartures(station: String) {
        let apiURL = "https://transport.opendata.ch/v1/stationboard?station=\(station)&limit=3"
        print("Departures from \(station) to \(destination)")

        
        guard let url = URL(string: apiURL) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(StationBoardResponse.self, from: data)
                    //                    let rawResponse = try JSONSerialization.jsonObject(with: data, options: [])
                    //                                print(rawResponse)  // This will give you the full JSON response
                    
                    
                    
                    DispatchQueue.main.async {
                        self.departures = response.stationboard.compactMap { entry in
                            if let date = ISO8601DateFormatter().date(from: entry.stop.departure) {
                                return Departure(time: date)
                            }
                            return nil
                        }
                        
                        
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            }
        }.resume()
    }
    

}
    

#Preview {
    ContentView()
}





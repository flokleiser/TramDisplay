import Foundation

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

let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.locale = Locale(identifier: "de_CH")
    return formatter
}()




class TransportService: ObservableObject {
    @Published var departures: [Departure] = []
    @Published var isLoading = false

    func fetchDepartures(station: String, destination: String) {
        let apiURL = "https://transport.opendata.ch/v1/stationboard?station=\(station.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? station)&limit=10"
        print("Departures from \(station) to \(destination)")
        print("Fetching from URL: \(apiURL)")


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
                            return
                        }

                        guard let data = data else { return }

                        do {
                            let response = try JSONDecoder().decode(StationBoardResponse.self, from: data)
                            print("Successfully decoded response with \(response.stationboard.count) connections")

                            let filteredDepartures = response.stationboard
                                .filter { connection in
                                    if let passList = connection.passList {
                                        return passList.contains { pass in
                                            pass.station.name == destination
                                        }
                                    }
                                    return false

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

                            if let decodingError = error as? DecodingError {
                                                   switch decodingError {
                                                   case .keyNotFound(let key, let context):
                                                       print("Key '\(key)' not found:", context.debugDescription)
                                                   case .valueNotFound(let type, let context):
                                                       print("Value of type '\(type)' not found:", context.debugDescription)
                                                   case .typeMismatch(let type, let context):
                                                       print("Type '\(type)' mismatch:", context.debugDescription)
                                                   case .dataCorrupted(let context):
                                                       print("Data corrupted:", context.debugDescription)
                                                   @unknown default:
                                                       print("Unknown decoding error")
                                                   }
                                               }
                        }
                    }
                }.resume()
    }


}


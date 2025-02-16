import SwiftUI
import WebKit

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
    
    let stations = ["Zürich, Rathaus", "Zürich, Toni-Areal", "Zürich, HB", "Zürich, Stadelhofen"]
    
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
            
            Button("Save Selection") {
                UserDefaults(suiteName: "group.com.yourapp")?.set(selectedStation, forKey: "selectedStation")
                UserDefaults(suiteName: "group.com.yourapp")?.set(selectedDestination, forKey: "selectedDestination")
            }
//            .padding()
            Divider()
                .padding()

            
                     
            Text("Widget Preview").font(.headline)

            WebView(urlString: "https://flokleiser.github.io/TransportAPITest/")
//                .padding(0.0)
                         .frame(height: 550)
                         .ignoresSafeArea()

        }
    }
}
    

#Preview {
    ContentView()
//    ViewController()
}



//embedded try:
//import WebKit

//class ViewController: UIViewController {
//    var webView: WKWebView!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        webView = WKWebView(frame: self.view.frame)
//        self.view.addSubview(webView)
//        if let url = URL(string: "https://flokleiser.github.io/TransportAPITest/") {
//            let request = URLRequest(url: url)
//            webView.load(request)
//        }
//    }
//}
//

import SwiftUI
struct ContentView: View {
    @State private var stationCount: Int = 0
    
    var body: some View {
        VStack {
            Text("Estaciones cargadas: \(stationCount)")
                .font(.title)
        }
        .task {
            await loadStations()
        }
    }
    
    func loadStations() async {
        do {
            let response = try await RadioAPIService.shared.fetchStations()
            stationCount = response.data.count
            print("✅ Cargadas \(response.total) estaciones")
        } catch {
            print("❌ Error: \(error.localizedDescription)")
        }
    }
}

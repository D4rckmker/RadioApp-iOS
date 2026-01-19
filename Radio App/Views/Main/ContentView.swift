import SwiftUI

struct ContentView: View {
    @State private var viewModel = StationsViewModel()
    
    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.stationsState {
                case .idle, .loading:
                    ProgressView("Cargando estaciones...")
                    
                case .loaded:
                    List(viewModel.filteredStations) { station in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(station.title)
                                .font(.headline)
                            Text(station.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(station.views) oyentes")
                                .font(.caption2)
                                .foregroundStyle(.blue)
                        }
                        .padding(.vertical, 4)
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                    
                case .error(let message):
                    ContentUnavailableView(
                        "Error al cargar",
                        systemImage: "wifi.exclamationmark",
                        description: Text(message)
                    )
                }
            }
            .navigationTitle("R Station")
        }
        .task {
            await viewModel.loadInitialData()
        }
    }
}

#Preview {
    ContentView()
}

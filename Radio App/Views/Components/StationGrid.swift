import SwiftUI

struct StationGrid: View {
    let stations: [Station]
    let currentStationId: String?
    let onStationTap: (Station) -> Void
    let onLoadMore: (() -> Void)?
    
    // Configuración del grid
    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(stations) { station in
                StationCard(
                    station: station,
                    isPlaying: station.id == currentStationId,
                    onTap: { onStationTap(station) }
                )
                .onAppear {
                    // Cargar más cuando llegamos al final
                    if station.id == stations.last?.id {
                        onLoadMore?()
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview
#Preview {
    ScrollView {
        StationGrid(
            stations: [.preview, .preview, .preview, .preview],
            currentStationId: nil,
            onStationTap: { _ in },
            onLoadMore: nil
        )
    }
}

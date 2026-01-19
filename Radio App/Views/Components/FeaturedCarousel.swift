import SwiftUI

struct FeaturedCarousel: View {
    let stations: [Station]
    let currentStationId: String?
    let onStationTap: (Station) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(stations) { station in
                    FeaturedCard(
                        station: station,
                        isPlaying: station.id == currentStationId,
                        onTap: { onStationTap(station) }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Tarjeta destacada grande
struct FeaturedCard: View {
    let station: Station
    let isPlaying: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .bottomLeading) {
                // Imagen de fondo
                AsyncImage(url: URL(string: station.urlLogo)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                .frame(width: 280, height: 160)
                .clipped()
                
                // Overlay gradiente
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Info de la estación
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(station.title)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        if !station.description.isEmpty {
                            Text(station.description)
                                .font(.caption)
                                .opacity(0.8)
                        }
                    }
                    
                    Spacer()
                    
                    // Botón de play
                    Circle()
                        .fill(.blue)
                        .frame(width: 44, height: 44)
                        .overlay {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                .foregroundStyle(.white)
                                .offset(x: isPlaying ? 0 : 2)
                        }
                }
                .padding()
                .foregroundStyle(.white)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview
#Preview {
    FeaturedCarousel(
        stations: [.preview, .preview, .preview],
        currentStationId: nil,
        onStationTap: { _ in }
    )
    .padding(.vertical)
    .background(Color.gray.opacity(0.1))
}

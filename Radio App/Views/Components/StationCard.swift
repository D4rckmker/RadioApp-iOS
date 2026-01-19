import SwiftUI

struct StationCard: View {
    let station: Station
    let isPlaying: Bool
    let onTap: () -> Void
    
    // Tamaño de la tarjeta
    var size: CardSize = .medium
    
    enum CardSize {
        case small   // Para listas
        case medium  // Para grid
        case large   // Para destacadas
        
        var imageSize: CGFloat {
            switch self {
            case .small: return 60
            case .medium: return 150
            case .large: return 200
            }
        }
        
        var cornerRadius: CGFloat {
            switch self {
            case .small: return 8
            case .medium: return 12
            case .large: return 16
            }
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                // Imagen de la estación
                stationImage
                
                // Info de la estación (solo para medium y large)
                if size != .small {
                    stationInfo
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Subvistas
    
    private var stationImage: some View {
        ZStack(alignment: .bottomTrailing) {
            // Imagen
            AsyncImage(url: URL(string: station.urlLogo)) { phase in
                switch phase {
                case .empty:
                    // Placeholder mientras carga
                    RoundedRectangle(cornerRadius: size.cornerRadius)
                        .fill(Color.gray.opacity(0.2))
                        .overlay {
                            ProgressView()
                        }
                    
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                    
                case .failure:
                    // Placeholder si falla
                    RoundedRectangle(cornerRadius: size.cornerRadius)
                        .fill(Color.gray.opacity(0.2))
                        .overlay {
                            Image(systemName: "radio")
                                .font(.title)
                                .foregroundStyle(.gray)
                        }
                    
                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: size.imageSize, height: size.imageSize)
            .clipShape(RoundedRectangle(cornerRadius: size.cornerRadius))
            
            // Indicador de reproducción
            if isPlaying {
                playingIndicator
            }
            
            // Badge de oyentes (solo para medium y large)
            if size != .small && station.views > 0 {
                listenersCountBadge
            }
        }
    }
    
    private var stationInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(station.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
            
            if !station.description.isEmpty {
                Text(station.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: size.imageSize, alignment: .leading)
    }
    
    private var playingIndicator: some View {
        Circle()
            .fill(.ultraThinMaterial)
            .frame(width: 32, height: 32)
            .overlay {
                Image(systemName: "waveform")
                    .font(.caption)
                    .foregroundStyle(.blue)
                    .symbolEffect(.variableColor.iterative, options: .repeating)
            }
            .padding(6)
    }
    
    private var listenersCountBadge: some View {
        HStack(spacing: 2) {
            Image(systemName: "headphones")
            Text("\(station.views)")
        }
        .font(.caption2)
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .padding(6)
    }
}

// MARK: - Preview
#Preview("Medium Card") {
    StationCard(
        station: .preview,
        isPlaying: false,
        onTap: {}
    )
    .padding()
}

#Preview("Playing Card") {
    StationCard(
        station: .preview,
        isPlaying: true,
        onTap: {}
    )
    .padding()
}

// MARK: - Preview Helper
extension Station {
    static var preview: Station {
        Station(
            title: "TITLE RADIO",
            description: "STREAMING RADIO",
            urlStreaming: "https://example.com/stream",
            urlApi: "",
            urlLogo: "https://example.com/logo.png",
            genres: [],
            countries: [],
            views: 180
        )
    }
}

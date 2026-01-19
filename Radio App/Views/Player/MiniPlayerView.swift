import SwiftUI

struct MiniPlayerView: View {
    @Bindable var playerViewModel: PlayerViewModel
    let namespace: Namespace.ID
    let onTap: () -> Void
    
    var body: some View {
        Group {
            if #available(iOS 26, *) {
                miniPlayerContent
                    .background(.regularMaterial, in: .rect(cornerRadius: 16))
                    .glassEffect(.regular.interactive())
                    .padding(.horizontal, 12)
                    .padding(.bottom, 4)
            } else {
                miniPlayerContent
                    .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
                    .padding(.horizontal, 12)
                    .padding(.bottom, 4)
            }
        }
    }
    
    // MARK: - Contenido del MiniPlayer
    private var miniPlayerContent: some View {
        HStack(spacing: 12) {
            // Artwork
            stationArtwork
                .matchedGeometryEffect(id: "artwork", in: namespace)
            
            // Info
            stationInfo
                .matchedGeometryEffect(id: "info", in: namespace)
            
            Spacer(minLength: 0)
            
            // Controles
            playPauseButton
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
    
    // MARK: - Artwork
    private var stationArtwork: some View {
        Group {
            if let station = playerViewModel.currentStation {
                AsyncImage(url: URL(string: station.urlLogo)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    default:
                        artworkPlaceholder
                    }
                }
            } else {
                artworkPlaceholder
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
    
    private var artworkPlaceholder: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.3))
            .overlay {
                Image(systemName: "radio")
                    .foregroundStyle(.gray)
            }
    }
    
    // MARK: - Station Info
    private var stationInfo: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(playerViewModel.displayTitle)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Text(playerViewModel.displayArtist)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
    }
    
    // MARK: - Play/Pause Button
    private var playPauseButton: some View {
        Button {
            playerViewModel.togglePlayPause()
        } label: {
            Group {
                if playerViewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: playerViewModel.isPlaying ? "pause.fill" : "play.fill")
                        .font(.title2)
                        .contentTransition(.symbolEffect(.replace))
                }
            }
            .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .disabled(playerViewModel.currentStation == nil)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @Namespace var namespace
    @Previewable @State var viewModel = PlayerViewModel()
    
    VStack {
        Spacer()
        MiniPlayerView(
            playerViewModel: viewModel,
            namespace: namespace,
            onTap: {}
        )
    }
    .background(Color.gray.opacity(0.1))
}

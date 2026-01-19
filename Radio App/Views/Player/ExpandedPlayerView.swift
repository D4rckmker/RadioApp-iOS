//
//  ExpandedPlayerView.swift
//  Radio App
//

import SwiftUI

struct ExpandedPlayerView: View {
    @Bindable var playerViewModel: PlayerViewModel
    let namespace: Namespace.ID
    @Environment(\.dismiss) private var dismiss
    
    // Estados locales
    @State private var volume: CGFloat = 0.6
    @State private var isVolumeSliderActive: Bool = false
    @State private var isDraggingDown: Bool = false
    @State private var dragOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fondo dinámico
                backgroundView
                
                // Contenido principal
                VStack(spacing: 0) {
                    // Drag indicator
                    dragIndicator
                        .padding(.top, 8)
                    
                    // Header
                    headerView
                        .padding(.top, 8)
                        .padding(.horizontal, 20)
                    
                    Spacer(minLength: 0)
                    
                    // Artwork
                    artworkView(size: min(geometry.size.width - 48, 340))
                    
                    Spacer(minLength: 0)
                    
                    // Info
                    infoView
                        .padding(.horizontal, 24)
                    
                    Spacer(minLength: 0)
                    
                    // Progress bar (simulado para radio en vivo)
                    liveIndicator
                        .padding(.horizontal, 24)
                    
                    Spacer(minLength: 0)
                    
                    // Controles principales
                    mainControls
                        .padding(.horizontal, 24)
                    
                    Spacer(minLength: 0)
                    
                    // Volumen estilo Apple Music
                    volumeSlider
                        .padding(.horizontal, 24)
                    
                    Spacer(minLength: 0)
                    
                    // Botones secundarios
                    secondaryControls
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                }
            }
            .offset(y: dragOffset)
        }
        .background(Color(.systemBackground))
        .gesture(dismissGesture)
        .navigationTransition(.zoom(sourceID: "artwork", in: namespace))
    }
    
    // MARK: - Dismiss Gesture
    private var dismissGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if value.translation.height > 0 {
                    dragOffset = value.translation.height * 0.5
                    isDraggingDown = true
                }
            }
            .onEnded { value in
                if value.translation.height > 120 {
                    dismiss()
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        dragOffset = 0
                        isDraggingDown = false
                    }
                }
            }
    }
    
    // MARK: - Background
    private var backgroundView: some View {
        ZStack {
            if let station = playerViewModel.currentStation {
                AsyncImage(url: URL(string: station.urlLogo)) { phase in
                    if case .success(let image) = phase {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: 100)
                            .saturation(1.5)
                            .opacity(0.8)
                            .scaleEffect(1.2)
                    }
                }
            } else {
                LinearGradient(
                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            
            // Overlay para legibilidad
            Color(.systemBackground).opacity(0.4)
        }
        .ignoresSafeArea()
    }
    
    // MARK: - Drag Indicator
    private var dragIndicator: some View {
        Capsule()
            .fill(Color.primary.opacity(0.4))
            .frame(width: 36, height: 5)
    }
    
    // MARK: - Header
    private var headerView: some View {
        HStack {
            // Botón cerrar
            glassButton(icon: "chevron.down", size: 32) {
                dismiss()
            }
            
            Spacer()
            
            // Título de la estación
            VStack(spacing: 2) {
                Text("REPRODUCIENDO DESDE")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                Text(playerViewModel.currentStation?.title ?? "R Station")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            
            Spacer()
            
            // Menú
            glassButton(icon: "ellipsis", size: 32) {
                // Menú de opciones
            }
        }
    }
    
    // MARK: - Glass Button
    private func glassButton(icon: String, size: CGFloat, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Group {
                if #available(iOS 26, *) {
                    Image(systemName: icon)
                        .font(.system(size: size * 0.4, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: size, height: size)
                        .background(.ultraThinMaterial, in: Circle())
                        .glassEffect(.regular)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: size * 0.4, weight: .semibold))
                        .foregroundStyle(.primary)
                        .frame(width: size, height: size)
                        .background(.ultraThinMaterial, in: Circle())
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Artwork
    private func artworkView(size: CGFloat) -> some View {
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
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.06))
        .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 15)
        .scaleEffect(isDraggingDown ? 0.95 : 1.0)
        .animation(.spring(response: 0.3), value: isDraggingDown)
        .matchedGeometryEffect(id: "artwork", in: namespace)
    }
    
    private var artworkPlaceholder: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(
                LinearGradient(
                    colors: [.blue.opacity(0.6), .purple.opacity(0.6)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Image(systemName: "radio")
                    .font(.system(size: 80))
                    .foregroundStyle(.white.opacity(0.8))
            }
    }
    
    // MARK: - Info View
    private var infoView: some View {
        VStack(spacing: 6) {
            // Título con animación marquee si es muy largo
            Text(playerViewModel.displayTitle)
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(1)
            
            Text(playerViewModel.displayArtist)
                .font(.title3)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Live Indicator
    private var liveIndicator: some View {
        HStack(spacing: 8) {
            // Indicador de en vivo
            HStack(spacing: 4) {
                Circle()
                    .fill(.red)
                    .frame(width: 8, height: 8)
                
                Text("EN VIVO")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
            }
            
            Spacer()
            
            // Oyentes
            if let station = playerViewModel.currentStation, station.views > 0 {
                HStack(spacing: 4) {
                    Image(systemName: "headphones")
                        .font(.caption2)
                    Text("\(station.views)")
                        .font(.caption2)
                        .fontWeight(.medium)
                }
                .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Main Controls
    private var mainControls: some View {
        HStack(spacing: 48) {
            // Estación anterior (deshabilitado para radio)
            Button {
                // Anterior
            } label: {
                Image(systemName: "backward.fill")
                    .font(.title)
                    .foregroundStyle(.primary.opacity(0.3))
            }
            .disabled(true)
            
            // Play/Pause principal
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    playerViewModel.togglePlayPause()
                }
            } label: {
                ZStack {
                    if playerViewModel.isLoading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.primary)
                    } else {
                        Image(systemName: playerViewModel.isPlaying ? "pause.fill" : "play.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.primary)
                            .scaleEffect(playerViewModel.isPlaying ? 1.0 : 1.0)
                            .offset(x: playerViewModel.isPlaying ? 0 : 4)
                            .contentTransition(.symbolEffect(.replace))
                    }
                }
                .frame(width: 80, height: 80)
            }
            .buttonStyle(PlayButtonStyle())
            
            // Estación siguiente (deshabilitado para radio)
            Button {
                // Siguiente
            } label: {
                Image(systemName: "forward.fill")
                    .font(.title)
                    .foregroundStyle(.primary.opacity(0.3))
            }
            .disabled(true)
        }
    }
    
    // MARK: - Volume Slider (Apple Music Style)
    private var volumeSlider: some View {
        HStack(spacing: 12) {
            Image(systemName: "speaker.fill")
                .font(.footnote)
                .foregroundStyle(.secondary)
            
            // Slider personalizado
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Track background
                    RoundedRectangle(cornerRadius: isVolumeSliderActive ? 6 : 3)
                        .fill(Color.primary.opacity(0.15))
                        .frame(height: isVolumeSliderActive ? 12 : 6)
                    
                    // Progress
                    RoundedRectangle(cornerRadius: isVolumeSliderActive ? 6 : 3)
                        .fill(Color.primary.opacity(0.6))
                        .frame(
                            width: geometry.size.width * volume,
                            height: isVolumeSliderActive ? 12 : 6
                        )
                }
                .frame(maxHeight: .infinity)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            withAnimation(.spring(response: 0.2)) {
                                isVolumeSliderActive = true
                            }
                            let newValue = value.location.x / geometry.size.width
                            volume = min(max(newValue, 0), 1)
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.3)) {
                                isVolumeSliderActive = false
                            }
                        }
                )
            }
            .frame(height: 24)
            
            Image(systemName: "speaker.wave.3.fill")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
    
    // MARK: - Secondary Controls
    private var secondaryControls: some View {
        HStack {
            // Lyrics/Info (no aplica para radio)
            glassButton(icon: "quote.bubble", size: 44) {
                // Info
            }
            
            Spacer()
            
            // AirPlay
            glassButton(icon: "airplayaudio", size: 44) {
                // AirPlay
            }
            
            Spacer()
            
            // Lista/Queue
            glassButton(icon: "list.bullet", size: 44) {
                // Historial
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Play Button Style
struct PlayButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Preview
#Preview {
    @Previewable @Namespace var namespace
    @Previewable @State var viewModel = PlayerViewModel()
    
    ExpandedPlayerView(
        playerViewModel: viewModel,
        namespace: namespace
    )
}

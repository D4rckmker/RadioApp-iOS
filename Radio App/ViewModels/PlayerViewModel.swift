import Foundation
import SwiftUI

// MARK: - ViewModel del reproductor
@MainActor
@Observable
final class PlayerViewModel {
    
    // MARK: - Propiedades públicas
    
    // Estación actual
    var currentStation: Station?
    
    // Info de reproducción actual
    var nowPlaying: NowPlaying?
    
    // Estado del reproductor
    var playerState: PlayerState = .stopped
    
    // Volumen (0.0 - 1.0)
    var volume: Float = 0.6
    
    // Historial de estaciones reproducidas
    var recentStations: [Station] = []
    
    // MARK: - Propiedades computadas
    
    /// Indica si hay una estación seleccionada
    var hasStation: Bool {
        currentStation != nil
    }
    
    /// Indica si está reproduciendo
    var isPlaying: Bool {
        if case .playing = playerState { return true } else { return false }
    }
    
    /// Indica si está cargando
    var isLoading: Bool {
        if case .loading = playerState { return true } else { return false }
    }
    
    /// Título para mostrar
    var displayTitle: String {
        nowPlaying?.displayTitle ?? currentStation?.title ?? "Sin estación"
    }
    
    /// Artista para mostrar
    var displayArtist: String {
        nowPlaying?.displayArtist ?? currentStation?.description ?? ""
    }
    
    // MARK: - Propiedades privadas
    
    private let audioService = AudioPlayerService.shared
    private let apiService = RadioAPIService.shared
    private var nowPlayingTask: Task<Void, Never>?
    
    // MARK: - Inicialización
    
    init() {
        setupAudioServiceCallback()
    }
    
    // MARK: - Configuración
    
    private func setupAudioServiceCallback() {
        audioService.onStateChange = { [weak self] state in
            Task { @MainActor in
                self?.playerState = state
                
                // Si empezó a reproducir, actualizar Now Playing info
                if case .playing = state {
                    self?.updateNowPlayingInfo()
                    self?.startNowPlayingUpdates()
                }
            }
        }
    }
    
    // MARK: - Control de reproducción
    
    /// Reproducir una estación
    func play(station: Station) {
        // Guardar estación actual
        currentStation = station
        
        // Agregar al historial (evitar duplicados)
        if !recentStations.contains(where: { $0.id == station.id }) {
            recentStations.insert(station, at: 0)
            // Mantener solo las últimas 10
            if recentStations.count > 10 {
                recentStations.removeLast()
            }
        }
        
        // Limpiar now playing anterior
        nowPlaying = nil
        
        // Iniciar reproducción
        audioService.play(urlString: station.urlStreaming)
        
        // Cargar info de Now Playing si tiene API
        if !station.urlApi.isEmpty {
            fetchNowPlaying()
        }
    }
    
    /// Pausar reproducción
    func pause() {
        audioService.pause()
    }
    
    /// Reanudar reproducción
    func resume() {
        audioService.resume()
    }
    
    /// Detener reproducción
    func stop() {
        stopNowPlayingUpdates()
        audioService.stop()
        audioService.clearNowPlayingInfo()
        nowPlaying = nil
    }
    
    /// Toggle play/pause
    func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }
    
    // MARK: - Now Playing
    
    /// Obtener info de canción actual desde la API de la estación
    private func fetchNowPlaying() {
        guard let station = currentStation,
              !station.urlApi.isEmpty,
              let url = URL(string: station.urlApi) else {
            return
        }
        
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                // Intentar decodificar (el formato puede variar según la estación)
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    await parseNowPlayingData(json)
                }
            } catch {
                print("❌ Error obteniendo Now Playing: \(error)")
            }
        }
    }
    
    /// Parsear datos de Now Playing (diferentes formatos de API)
    private func parseNowPlayingData(_ json: [String: Any]) async {
        // Formato 1: Directo
        if let title = json["title"] as? String {
            nowPlaying = NowPlaying(
                title: title,
                artist: json["artist"] as? String,
                albumArt: json["artwork"] as? String ?? json["art"] as? String
            )
        }
        // Formato 2: Azuracast (now_playing.song)
        else if let nowPlayingData = json["now_playing"] as? [String: Any],
                let song = nowPlayingData["song"] as? [String: Any] {
            nowPlaying = NowPlaying(
                title: song["title"] as? String,
                artist: song["artist"] as? String,
                albumArt: song["art"] as? String
            )
        }
        // Formato 3: Icecast/Shoutcast
        else if let songTitle = json["songtitle"] as? String ?? json["song"] as? String {
            // Formato típico: "Artista - Canción"
            let parts = songTitle.components(separatedBy: " - ")
            if parts.count >= 2 {
                nowPlaying = NowPlaying(
                    title: parts[1],
                    artist: parts[0],
                    albumArt: nil
                )
            } else {
                nowPlaying = NowPlaying(
                    title: songTitle,
                    artist: nil,
                    albumArt: nil
                )
            }
        }
        
        // Actualizar Control Center
        updateNowPlayingInfo()
    }
    
    /// Iniciar actualizaciones periódicas de Now Playing
    private func startNowPlayingUpdates() {
        stopNowPlayingUpdates()
        
        nowPlayingTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))  // Actualizar cada 30 segundos
                if !Task.isCancelled {
                    fetchNowPlaying()
                }
            }
        }
    }
    
    /// Detener actualizaciones de Now Playing
    private func stopNowPlayingUpdates() {
        nowPlayingTask?.cancel()
        nowPlayingTask = nil
    }
    
    /// Actualizar información en Control Center
    private func updateNowPlayingInfo() {
        guard let station = currentStation else { return }
        
        audioService.updateNowPlayingInfo(
            title: nowPlaying?.displayTitle ?? "En vivo",
            artist: nowPlaying?.displayArtist ?? station.title,
            stationName: station.title
        )
    }
}

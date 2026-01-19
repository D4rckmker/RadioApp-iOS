import AVFoundation
import MediaPlayer

// MARK: - Servicio de reproducción de audio
final class AudioPlayerService {
    
    // Singleton
    static let shared = AudioPlayerService()
    
    // AVPlayer para streaming
    private var player: AVPlayer?
    private var playerItem: AVPlayerItem?
    
    // Observadores
    private var timeObserver: Any?
    private var statusObserver: NSKeyValueObservation?
    
    // Callback para notificar cambios de estado
    var onStateChange: ((PlayerState) -> Void)?
    
    // MARK: - Inicialización
    private init() {
        setupAudioSession()
        setupRemoteCommandCenter()
    }
    
    // MARK: - Configuración de sesión de audio
    private func setupAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            // .playback permite reproducir en background
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true)
        } catch {
            print("❌ Error configurando audio session: \(error)")
        }
    }
    
    // MARK: - Configuración de controles remotos (Control Center, AirPods, etc.)
    private func setupRemoteCommandCenter() {
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Botón Play
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            self?.resume()
            return .success
        }
        
        // Botón Pause
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            self?.pause()
            return .success
        }
        
        // Botón Stop
        commandCenter.stopCommand.isEnabled = true
        commandCenter.stopCommand.addTarget { [weak self] _ in
            self?.stop()
            return .success
        }
        
        // Toggle Play/Pause (para audífonos)
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            self?.togglePlayPause()
            return .success
        }
    }
    
    // MARK: - Control de reproducción
    
    /// Reproducir una URL de streaming
    func play(url: URL) {
        // Detener reproducción anterior
        stop()
        
        // Crear nuevo player item
        playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        
        // Observar estado del player
        observePlayerStatus()
        
        // Iniciar reproducción
        player?.play()
        onStateChange?(.loading)
    }
    
    /// Reproducir desde string URL
    func play(urlString: String) {
        guard let url = URL(string: urlString) else {
            onStateChange?(.error("URL inválida"))
            return
        }
        play(url: url)
    }
    
    /// Pausar reproducción
    func pause() {
        player?.pause()
        onStateChange?(.stopped)
    }
    
    /// Reanudar reproducción
    func resume() {
        player?.play()
        onStateChange?(.playing)
    }
    
    /// Detener completamente
    func stop() {
        player?.pause()
        player = nil
        playerItem = nil
        statusObserver?.invalidate()
        statusObserver = nil
        onStateChange?(.stopped)
    }
    
    /// Toggle play/pause
    func togglePlayPause() {
        if player?.timeControlStatus == .playing {
            pause()
        } else {
            resume()
        }
    }
    
    /// Verificar si está reproduciendo
    var isPlaying: Bool {
        player?.timeControlStatus == .playing
    }
    
    // MARK: - Observadores
    
    private func observePlayerStatus() {
        statusObserver = playerItem?.observe(\.status, options: [.new]) { [weak self] item, _ in
            DispatchQueue.main.async {
                switch item.status {
                case .readyToPlay:
                    self?.onStateChange?(.playing)
                case .failed:
                    let message = item.error?.localizedDescription ?? "Error desconocido"
                    self?.onStateChange?(.error(message))
                case .unknown:
                    self?.onStateChange?(.loading)
                @unknown default:
                    break
                }
            }
        }
    }
    
    // MARK: - Now Playing Info (Control Center)
    
    /// Actualizar información en Control Center
    func updateNowPlayingInfo(
        title: String,
        artist: String,
        stationName: String,
        artwork: UIImage? = nil
    ) {
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: title,
            MPMediaItemPropertyArtist: artist,
            MPMediaItemPropertyAlbumTitle: stationName,
            MPNowPlayingInfoPropertyIsLiveStream: true
        ]
        
        // Agregar artwork si existe
        if let image = artwork {
            let artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
            info[MPMediaItemPropertyArtwork] = artwork
        }
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }
    
    /// Limpiar info del Control Center
    func clearNowPlayingInfo() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }
}

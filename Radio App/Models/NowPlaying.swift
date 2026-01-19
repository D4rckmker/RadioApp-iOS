import Foundation

// MARK: - Información de reproducción actual
struct NowPlaying: Codable {
    let title: String?
    let artist: String?
    let albumArt: String?
    
    // Valores por defecto cuando no hay info
    var displayTitle: String {
        title ?? "Sin información"
    }
    
    var displayArtist: String {
        artist ?? "Artista desconocido"
    }
}

// MARK: - Estado del reproductor
enum PlayerState: Equatable {
    case stopped
    case loading
    case playing
    case error(String)
}

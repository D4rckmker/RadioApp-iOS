import Foundation

// MARK: - Modelo principal de Estación
struct Station: Codable, Identifiable {
    // Usamos title como id ya que la API no provee uno único
    var id: String { title }
    
    let title: String
    let description: String
    let urlStreaming: String
    let urlApi: String
    let urlLogo: String
    let genres: [Genre]
    let countries: [Country]
    let views: Int
    
    // Mapeo de nombres JSON (snake_case) a Swift (camelCase)
    enum CodingKeys: String, CodingKey {
        case title
        case description
        case urlStreaming = "url_streaming"
        case urlApi = "url_api"
        case urlLogo = "url_logo"
        case genres
        case countries
        case views
    }
}

// MARK: - Género musical
struct Genre: Codable, Identifiable {
    let id: Int
    let name: String
    let slug: String
    let icon: String
}

// MARK: - País
struct Country: Codable, Identifiable {
    let id: Int
    let name: String
    let slug: String
    let icon: String
}

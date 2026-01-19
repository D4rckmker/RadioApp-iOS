import Foundation

// MARK: - Respuesta genérica de la API
struct APIResponse<T: Codable>: Codable {
    let success: Bool
    let data: T
}

// MARK: - Respuesta paginada de estaciones
struct StationsResponse: Codable {
    let success: Bool
    let data: [Station]
    let page: Int
    let perPage: Int
    let total: Int
    let totalPages: Int
    
    enum CodingKeys: String, CodingKey {
        case success, data, page, total
        case perPage = "per_page"
        case totalPages = "total_pages"
    }
}

// MARK: - Género simple (para lista de géneros)
struct GenreSimple: Codable, Identifiable {
    var id: String { name }
    
    let name: String
    let flagIcon: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case flagIcon = "flag_icon"
    }
}

// MARK: - País simple (para lista de países)
struct CountrySimple: Codable, Identifiable {
    var id: String { name }
    
    let name: String
    let flagIcon: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case flagIcon = "flag_icon"
    }
}

// MARK: - Slider/Banner
struct Slider: Codable, Identifiable {
    var id: String { image }
    
    let image: String
    let url: String
}

// MARK: - Configuración de Sliders
struct SlidersResponse: Codable {
    let success: Bool
    let autoplay: Bool
    let duration: Int
    let data: [Slider]
}

// MARK: - Redes Sociales
struct SocialLinks: Codable {
    let facebook: String
    let xTwitter: String
    let tiktok: String
    let whatsapp: String
    let instagram: String
    let youtube: String
    let telegram: String
    
    enum CodingKeys: String, CodingKey {
        case facebook
        case xTwitter = "x_twitter"
        case tiktok, whatsapp, instagram, youtube, telegram
    }
}

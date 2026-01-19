import Foundation

// MARK: - Errores de la API
enum APIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida"
        case .invalidResponse:
            return "Respuesta inválida del servidor"
        case .networkError(let error):
            return "Error de red: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Error al procesar datos: \(error.localizedDescription)"
        case .serverError(let code):
            return "Error del servidor: \(code)"
        }
    }
}

// MARK: - Servicio de API
final class RadioAPIService {
    
    // Singleton: Una única instancia compartida en toda la app
    static let shared = RadioAPIService()
    
    // Configuración privada
    private let baseURL = Secrets.baseURL
    private let apiKey = Secrets.apiKey
    private let session: URLSession
    
    // Inicializador privado (para forzar uso del singleton)
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - Método base para todas las peticiones
    private func performRequest<T: Codable>(
        endpoint: String,
        responseType: T.Type
    ) async throws -> T {
        // 1. Construir URL
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            throw APIError.invalidURL
        }
        
        // 2. Configurar request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 3. Realizar petición
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }
        
        // 4. Verificar respuesta HTTP
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.serverError(httpResponse.statusCode)
        }
        
        // 5. Decodificar JSON
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    // MARK: - Endpoints públicos
    
    /// Obtener lista de estaciones (paginada)
    func fetchStations(page: Int = 1) async throws -> StationsResponse {
        // Para paginación, necesitamos enviar body
        guard let url = URL(string: "\(baseURL)/stations") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Body para paginación (si tu API lo requiere)
        let body = ["page": page]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
        
        do {
            return try JSONDecoder().decode(StationsResponse.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    /// Obtener estaciones destacadas
    func fetchFeaturedStations() async throws -> [Station] {
        let response = try await performRequest(
            endpoint: "features",
            responseType: APIResponse<[Station]>.self
        )
        return response.data
    }
    
    /// Obtener lista de géneros
    func fetchGenres() async throws -> [GenreSimple] {
        let response = try await performRequest(
            endpoint: "genres",
            responseType: APIResponse<[GenreSimple]>.self
        )
        return response.data
    }
    
    /// Obtener lista de países
    func fetchCountries() async throws -> [CountrySimple] {
        let response = try await performRequest(
            endpoint: "country",
            responseType: APIResponse<[CountrySimple]>.self
        )
        return response.data
    }
    
    /// Obtener configuración de sliders
    func fetchSliders() async throws -> SlidersResponse {
        return try await performRequest(
            endpoint: "slider",
            responseType: SlidersResponse.self
        )
    }
    
    /// Obtener enlaces de redes sociales
    func fetchSocialLinks() async throws -> SocialLinks {
        let response = try await performRequest(
            endpoint: "socials",
            responseType: APIResponse<SocialLinks>.self
        )
        return response.data
    }
}

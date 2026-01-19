import Foundation

// MARK: - Estados de carga
enum LoadingState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}

// MARK: - ViewModel principal de estaciones
@MainActor
@Observable
final class StationsViewModel {
    
    // MARK: - Propiedades publicadas
    
    // Datos
    var stations: [Station] = []
    var featuredStations: [Station] = []
    var genres: [GenreSimple] = []
    var countries: [CountrySimple] = []
    var sliders: [Slider] = []
    
    // Estados de carga
    var stationsState: LoadingState = .idle
    var featuredState: LoadingState = .idle
    var genresState: LoadingState = .idle
    
    // Paginación
    var currentPage: Int = 1
    var totalPages: Int = 1
    var canLoadMore: Bool { currentPage < totalPages }
    
    // Filtros
    var selectedGenre: String? = nil
    var searchText: String = ""
    
    // MARK: - Propiedades privadas
    private let apiService = RadioAPIService.shared
    
    // MARK: - Computed Properties
    
    /// Estaciones filtradas por género y búsqueda
    var filteredStations: [Station] {
        var result = stations
        
        // Filtrar por género
        if let genre = selectedGenre {
            result = result.filter { station in
                station.genres.contains { $0.name == genre }
            }
        }
        
        // Filtrar por búsqueda
        if !searchText.isEmpty {
            result = result.filter { station in
                station.title.localizedCaseInsensitiveContains(searchText) ||
                station.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    /// Indica si está cargando algo
    var isLoading: Bool {
        stationsState == .loading || featuredState == .loading
    }
    
    // MARK: - Métodos públicos
    
    /// Carga inicial de todos los datos
    func loadInitialData() async {
        // Cargar todo en paralelo para mayor velocidad
        async let stationsTask: () = loadStations()
        async let featuredTask: () = loadFeaturedStations()
        async let genresTask: () = loadGenres()
        async let countriesTask: () = loadCountries()
        async let slidersTask: () = loadSliders()
        
        // Esperar a que todo termine
        _ = await (stationsTask, featuredTask, genresTask, countriesTask, slidersTask)
    }
    
    /// Cargar estaciones (primera página o refresh)
    func loadStations() async {
        stationsState = .loading
        currentPage = 1
        
        do {
            let response = try await apiService.fetchStations(page: 1)
            stations = response.data
            totalPages = response.totalPages
            stationsState = .loaded
        } catch {
            stationsState = .error(error.localizedDescription)
            print("❌ Error cargando estaciones: \(error)")
        }
    }
    
    /// Cargar más estaciones (paginación)
    func loadMoreStations() async {
        guard canLoadMore, stationsState != .loading else { return }
        
        let nextPage = currentPage + 1
        
        do {
            let response = try await apiService.fetchStations(page: nextPage)
            stations.append(contentsOf: response.data)
            currentPage = nextPage
            totalPages = response.totalPages
        } catch {
            print("❌ Error cargando más estaciones: \(error)")
        }
    }
    
    /// Cargar estaciones destacadas
    func loadFeaturedStations() async {
        featuredState = .loading
        
        do {
            featuredStations = try await apiService.fetchFeaturedStations()
            featuredState = .loaded
        } catch {
            featuredState = .error(error.localizedDescription)
            print("❌ Error cargando destacadas: \(error)")
        }
    }
    
    /// Cargar géneros
    func loadGenres() async {
        genresState = .loading
        
        do {
            genres = try await apiService.fetchGenres()
            genresState = .loaded
        } catch {
            genresState = .error(error.localizedDescription)
            print("❌ Error cargando géneros: \(error)")
        }
    }
    
    /// Cargar países
    func loadCountries() async {
        do {
            countries = try await apiService.fetchCountries()
        } catch {
            print("❌ Error cargando países: \(error)")
        }
    }
    
    /// Cargar sliders
    func loadSliders() async {
        do {
            let response = try await apiService.fetchSliders()
            sliders = response.data
        } catch {
            print("❌ Error cargando sliders: \(error)")
        }
    }
    
    /// Refrescar todos los datos (pull to refresh)
    func refresh() async {
        await loadInitialData()
    }
    
    /// Limpiar filtro de género
    func clearGenreFilter() {
        selectedGenre = nil
    }
    
    /// Seleccionar un género
    func selectGenre(_ genre: String) {
        if selectedGenre == genre {
            selectedGenre = nil  // Toggle: si ya está seleccionado, deseleccionar
        } else {
            selectedGenre = genre
        }
    }
}

import SwiftUI

struct GenreFilterPicker: View {
    let genres: [GenreSimple]
    @Binding var selectedGenre: String?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // Opción "Todos"
                FilterChip(
                    title: "Todos",
                    isSelected: selectedGenre == nil,
                    onTap: { selectedGenre = nil }
                )
                
                // Géneros disponibles
                ForEach(genres) { genre in
                    FilterChip(
                        title: genre.name,
                        isSelected: selectedGenre == genre.name,
                        onTap: {
                            if selectedGenre == genre.name {
                                selectedGenre = nil  // Deseleccionar
                            } else {
                                selectedGenre = genre.name
                            }
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Chip individual
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.accentColor : Color.gray.opacity(0.15))
                )
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Preview Wrapper
struct GenreFilterPicker_PreviewWrapper: View {
    @State private var selected: String? = nil

    private let sampleGenres: [GenreSimple] = [
        // Adjust to your actual initializer for GenreSimple
        GenreSimple(name: "Pop", flagIcon: ""),
        GenreSimple(name: "Rock", flagIcon: ""),
        GenreSimple(name: "Latin", flagIcon: ""),
        GenreSimple(name: "Cristiana", flagIcon: ""),
        GenreSimple(name: "Electrónica", flagIcon: "")
    ]

    var body: some View {
        VStack {
            GenreFilterPicker(
                genres: sampleGenres,
                selectedGenre: $selected
            )
            Text("Seleccionado: \(selected ?? "Todos")")
                .padding()
        }
        .padding()
    }
}

#Preview("GenreFilterPicker") {
    GenreFilterPicker_PreviewWrapper()
}

import SwiftData
import SwiftUI

struct ArtistList: View {
    @State private var query: String = ""
    @State private var isAdding: Bool = false

    @Query private var artists: [Artist]

    private var filteredArtists: [Artist] {
        if query == "" {
            artists
        } else {
            artists.filter { $0.name.localizedStandardContains(query) }
        }
    }

    var body: some View {
        var groupedArtists: [String: [Artist]] {
            Dictionary(grouping: filteredArtists) { String($0.name.prefix(1)) }
        }

        List {
            ForEach(Array(groupedArtists.keys.sorted()), id: \.self) { firstLetter in
                Section(header: Text(firstLetter)) {
                    let artistsByLetter: [Artist]? = groupedArtists[firstLetter]?.sorted {
                        $0.name < $1.name
                    }

                    ForEach(artistsByLetter ?? [], id: \.id) { artist in
                        NavigationLink {
                            ArtistDetail(artist: artist)
                        } label: {
                            MultilineArtistRow(artist: artist)
                        }
                    }
                }
                .headerProminence(.increased)
            }
        }
        .navigationTitle("Artistas")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isAdding) {
            ArtistEditor(artist: Artist?(nil))
        }
        .toolbar { AddButtonToolbarItem(isAdding: $isAdding) }
        .searchable(text: $query, prompt: Text("Buscar"))
    }
}

#Preview {
    let artistType = ArtistType(name: "Regente")
    let artist = Artist(name: "Fabio Mechetti", type: artistType)

    NavigationStack {
        //ArtistList()
        //ArtistEditor(artist: artist)
        ArtistDetail(artist: artist)
    }
}

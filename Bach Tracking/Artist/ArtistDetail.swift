import CoreSpotlight
import SwiftData
import SwiftUI

struct ArtistDetail: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext

    @State private var isEditing = false

    let artist: Artist

    var body: some View {
        List {
            Text(artist.type.name).listRowSeparator(.hidden)

            Portrait(name: artist.name)

            if !artist.concerts.isEmpty {
                ProminentSection("Concertos") {
                    ForEach(artist.concerts) { concert in
                        NavigationLink {
                            ConcertDetail(concert: concert)
                        } label: {
                            MultilineConcertRow(concert: concert)
                        }
                    }
                }
            }

            if artist.name.count > 20 {
                ProminentSection("Nome") { Text(artist.name) }
            }
        }
        .listStyle(.plain)
        .navigationTitle(artist.name)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $isEditing) {
            ArtistEditor(artist: artist)
        }
        .toolbar { EditButtonToolbarItem(isEditing: $isEditing) }

        if artist.performances.isEmpty {
            DeleteButton(item: artist) {
                CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [
                    "artist.\(artist.id.uuidString)"
                ])
            }
        }
    }
}

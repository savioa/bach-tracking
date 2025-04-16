import CoreSpotlight
import SwiftData
import SwiftUI

struct ArtistEditor: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext

    @State private var name: String = ""
    @State private var type: ArtistType?
    @State private var newArtist: Bool = true

    @Query(sort: \ArtistType.name) private var artistTypes: [ArtistType]

    let artist: Artist?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nome", text: $name).textInputAutocapitalization(.words)

                    CustomMenuPicker(
                        title: "Tipo", items: artistTypes, selection: $type, label: { $0.name })
                }
            }
            .navigationTitle(newArtist ? "Novo Artista" : "")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar", role: .cancel) { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") { save() }.disabled(name.isEmpty || type == nil)
                }
            }
        }
        .onAppear {
            if let artist: Artist {
                name = artist.name
                type = artist.type
                newArtist = false
            }
        }
    }

    func save() {
        let indexingArtist: Artist

        if let artist: Artist {
            artist.name = name.trimmed
            artist.type = type!
            indexingArtist = artist
        } else {
            let artist: Artist = Artist(name: name.trimmed, type: type!)

            modelContext.insert(artist)
            indexingArtist = artist
        }

        try? modelContext.save()

        indexArtistInSpotlight(indexingArtist)

        dismiss()
    }

    func indexArtistInSpotlight(_ artist: Artist) {
        let attributeSet: CSSearchableItemAttributeSet = CSSearchableItemAttributeSet(
            itemContentType: UTType.text.identifier)

        attributeSet.title = artist.name
        attributeSet.contentDescription = artist.type.name
        attributeSet.keywords = [artist.name, artist.type.name]
        attributeSet.thumbnailData = safeThumbnailData(for: artist.name)

        let item: CSSearchableItem = CSSearchableItem(
            uniqueIdentifier: "artist.\(artist.id.uuidString)",
            domainIdentifier: "com.seudominio.bachtracking.artist",
            attributeSet: attributeSet
        )

        CSSearchableIndex.default().indexSearchableItems([item])
    }
}

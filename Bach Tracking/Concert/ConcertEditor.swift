import SwiftData
import SwiftUI

struct ConcertEditor: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext

    @State private var name: String = ""
    @State private var date: Date = Date.now
    @State private var venue: Venue?
    @State private var series: Series?
    @State private var seriesInstance: String = ""
    @State private var performances: [Performance] = []
    @State private var newConcert: Bool = true
    @State private var isAddingWork: Bool = false
    @State private var removedPerformances: [Performance] = []

    @Query(sort: \Venue.name) private var venues: [Venue]
    @Query(sort: \Series.name) private var seriesList: [Series]

    var instance: Int? {
        Int(seriesInstance)
    }

    let concert: Concert?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nome", text: $name).textInputAutocapitalization(.words)

                    DatePicker(selection: $date) {
                        Text("Data")
                    }

                    CustomMenuPicker(
                        title: "Local", items: venues, selection: $venue, label: { $0.name })

                    CustomMenuPicker(
                        title: "Série", items: seriesList, selection: $series, label: { $0.name },
                        nilTitle: "Não faz parte de uma série")

                    if series != nil {
                        TextField("Número na série", text: $seriesInstance).keyboardType(.numberPad)
                    }
                }

                Section(
                    header: SectionHeaderWithAddButton(
                        sectionHeaderText: "Obras", accessibilityLabel: "Adicionar nova obra",
                        isAdding: $isAddingWork)
                ) {
                    if performances.isEmpty {
                        Text("Nenhuma obra cadastrada")
                    } else {
                        ForEach(performances) { performance in
                            MultilinePerformanceRow(performance: performance)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        performances.removeAll { $0.id == performance.id }
                                        removedPerformances.append(performance)
                                    } label: {
                                        Label("Remover", systemImage: "minus.circle.fill")
                                    }
                                }
                        }
                    }
                }
                .headerProminence(.increased)

                if !performances.isEmpty {
                    let uniqueArtists: [Artist] = Set(performances.flatMap { $0.artists })
                        .sorted { $0.name < $1.name }

                    Section("Artistas") {
                        ForEach(uniqueArtists) { artist in
                            MultilineArtistRow(artist: artist)
                        }
                    }
                    .headerProminence(.increased)
                }
            }
            .onChange(of: series) {
                if series == nil {
                    seriesInstance = ""
                }
            }
            .navigationTitle(newConcert ? "Novo Concerto" : "")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $isAddingWork) {
                PerformanceEditor(
                    referencedArtists: Set(performances.flatMap { $0.artists }).sorted {
                        $0.name < $1.name
                    }
                ) { newPerformance in
                    performances.append(newPerformance)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar") { save() }
                        .disabled(
                            (name.isEmpty && series == nil) || performances.isEmpty || venue == nil)
                }
            }
        }
        .onAppear {
            if let concert: Concert {
                name = concert.name
                date = concert.date
                venue = concert.venue
                series = concert.series
                seriesInstance = concert.seriesInstance.map(String.init) ?? ""
                performances = concert.performances.sorted { !$0.encore && $1.encore }
                newConcert = false
            }
        }
    }

    func save() {
        if let concert: Concert {
            removedPerformances.forEach { performance in
                modelContext.delete(performance)
            }

            concert.name = name.trimmed
            concert.date = date
            concert.venue = venue!
            concert.series = series
            concert.seriesInstance = instance
            concert.performances = performances
        } else {
            let concert: Concert = Concert(
                date: date, venue: venue!, series: series, seriesInstance: instance,
                name: name.trimmed, performances: performances)

            modelContext.insert(concert)
        }

        try? modelContext.save()

        dismiss()
    }
}

struct PerformanceEditor: View {
    @Environment(\.dismiss) var dismiss: DismissAction

    @State private var composer: Composer?
    @State private var work: Work?
    @State private var detail: String = ""
    @State private var artists: [Artist] = []
    @State private var isEncore: Bool = false
    @State private var isAddingArtist: Bool = false

    @Query(sort: \Composer.shortName) private var composers: [Composer]

    let referencedArtists: [Artist]

    var onAdd: (Performance) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    CustomMenuPicker(
                        title: "Compositor", items: composers.filter { !$0.works.isEmpty },
                        selection: $composer, label: { $0.shortName }
                    )
                    .onChange(of: composer) {
                        work = nil

                        if let composer: Composer, composer.works.count == 1 {
                            work = composer.works.first
                        }
                    }

                    CustomMenuPicker(
                        title: "Obra",
                        items: composer?.works.sorted { $0.primaryTitle < $1.primaryTitle } ?? [],
                        selection: $work, label: { $0.primaryTitle }
                    )

                    Picker("Bis", selection: $isEncore) {
                        Text("-").tag(false)
                        Text("Bis").tag(true)
                    }
                    .pickerStyle(.segmented)

                    TextField("Detalhe", text: $detail)
                }

                Section(
                    header: SectionHeaderWithAddButton(
                        sectionHeaderText: "Artistas", accessibilityLabel: "Adicionar novo artista",
                        isAdding: $isAddingArtist)
                ) {
                    if artists.isEmpty {
                        Text("Nenhum artista cadastrado")
                    } else {
                        ForEach(artists) { artist in
                            MultilineArtistRow(artist: artist)
                                .swipeActions(edge: .trailing) {
                                    Button(role: .destructive) {
                                        artists.removeAll { $0.id == artist.id }
                                    } label: {
                                        Label("Remover", systemImage: "minus.circle.fill")
                                    }
                                }
                        }
                    }
                }
                .headerProminence(.increased)

                let suggestions: [Artist] = referencedArtists.filter { referenced in
                    !artists.contains(where: { $0.id == referenced.id })
                }

                if suggestions.count > 0 {
                    Section(
                        header: Text("Sugestões"),
                        footer: Text("Clique em um artista para relacioná-lo à execução da obra")
                    ) {
                        ForEach(suggestions) { artist in
                            Button {
                                if !artists.contains(where: { $0.id == artist.id }) {
                                    artists.append(artist)
                                }
                            } label: {
                                MultilineArtistRow(artist: artist)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .headerProminence(.increased)
                }
            }
            .sheet(isPresented: $isAddingArtist) {
                ArtistListEditor { newArtist in
                    artists.append(newArtist)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar", role: .cancel) { dismiss() }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Adicionar") {
                        onAdd(
                            Performance(
                                work: work!, artists: artists, detail: detail, encore: isEncore))
                        dismiss()
                    }
                    .disabled(artists.isEmpty || work == nil)
                }
            }
        }
    }
}

struct ArtistListEditor: View {
    @Environment(\.dismiss) var dismiss: DismissAction

    @State private var artistType: ArtistType?
    @State private var artist: Artist?

    @Query(sort: \ArtistType.name) private var artistTypes: [ArtistType]

    var onAdd: (Artist) -> Void

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    CustomMenuPicker(
                        title: "Tipo de artista",
                        items: artistTypes.filter { !($0.artists.isEmpty) },
                        selection: $artistType, label: { $0.name }
                    )
                    .onChange(of: artistType) {
                        artist = nil

                        if let artistType: ArtistType, artistType.artists.count == 1 {
                            artist = artistType.artists.first
                        }
                    }

                    CustomMenuPicker(
                        title: "Artista",
                        items: artistType?.artists.sorted { $0.name < $1.name } ?? [],
                        selection: $artist, label: { $0.name }
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar", role: .cancel) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Adicionar") {
                        onAdd(artist!)
                        dismiss()
                    }
                    .disabled(artist == nil)
                }
            }
        }
    }
}

import SwiftData
import SwiftUI

struct ConcertEditor: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext

    @State private var name = ""
    @State private var date = Date.now
    @State private var venue: Venue?
    @State private var series: Series?
    @State private var seriesInstance = ""
    @State private var performances: [Performance] = []
    @State private var navigationTitle = "Novo Concerto"
    @State private var isAddingWork = false
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

                ProminentSection(
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

                if !performances.isEmpty {
                    let uniqueArtists = Set(performances.flatMap { $0.artists })
                        .sorted { $0.name < $1.name }

                    ProminentSection("Artistas") {
                        ForEach(uniqueArtists) { artist in
                            MultilineArtistRow(artist: artist)
                        }
                    }
                }
            }
            .onChange(of: series) {
                if series == nil {
                    seriesInstance = ""
                }
            }
            .navigationTitle(navigationTitle)
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
                FormToolbar.items(
                    isConfirmDisabled: (name.isEmpty && series == nil) || performances.isEmpty
                        || venue == nil, onConfirm: { save() })
            }
        }
        .onAppear {
            if let concert {
                name = concert.name
                date = concert.date
                venue = concert.venue
                series = concert.series
                seriesInstance = concert.seriesInstance.map(String.init) ?? ""
                performances = concert.performances.sorted { !$0.encore && $1.encore }
                navigationTitle = ""
            }
        }
    }

    func save() {
        if let concert {
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
            let concert = Concert(
                date: date, venue: venue!, series: series, seriesInstance: instance,
                name: name.trimmed, performances: performances)

            modelContext.insert(concert)
        }

        try? modelContext.save()

        registerNotification()

        dismiss()
    }

    fileprivate func registerNotification() {
        if let concert {
            let content = UNMutableNotificationContent()
            content.title = "Um ano atrás..."
            content.subtitle = "\(concert.title)"
            content.body = concert.performances.compactMap { $0.work.composer.shortName }.joined(
                separator: ", ")
            content.sound = UNNotificationSound.default

            let oneYearLater = Calendar.current.date(byAdding: .year, value: 1, to: concert.date)!

            var dateComponents = Calendar.current.dateComponents(
                [.year, .month, .day], from: oneYearLater)
            dateComponents.hour = 9

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents, repeats: false)

            let request = UNNotificationRequest(
                identifier: concert.id.uuidString, content: content,
                trigger: trigger)

            UNUserNotificationCenter.current().add(request)
        }
    }
}

struct PerformanceEditor: View {
    @Environment(\.dismiss) var dismiss: DismissAction

    @State private var composer: Composer?
    @State private var work: Work?
    @State private var detail = ""
    @State private var artists: [Artist] = []
    @State private var isEncore = false
    @State private var isAddingArtist = false

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

                        if let composer, composer.works.count == 1 {
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

                ProminentSection(
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

                let suggestions = referencedArtists.filter { referenced in
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
                FormToolbar.items(
                    confirmLabel: "Adicionar",
                    isConfirmDisabled: artists.isEmpty || work == nil,
                    onConfirm: {
                        onAdd(
                            Performance(
                                work: work!, artists: artists, detail: detail, encore: isEncore))
                        dismiss()
                    })
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

                        if let artistType, artistType.artists.count == 1 {
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
                FormToolbar.items(
                    confirmLabel: "Adicionar",
                    isConfirmDisabled: artist == nil,
                    onConfirm: {
                        onAdd(artist!)
                        dismiss()
                    })
            }
        }
    }
}

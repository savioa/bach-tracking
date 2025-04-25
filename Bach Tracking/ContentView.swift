import Combine
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext: ModelContext

    @EnvironmentObject var spotlightManager: SpotlightNavigationManager

    @StateObject private var searchManager = SearchManager()

    @State private var navigationPath = NavigationPath()

    @State private var isShowingSpotlightItemDetail = false
    @State private var selectedComposer: Composer?
    @State private var selectedWork: Work?
    @State private var selectedArtist: Artist?

    var body: some View {
        NavigationStack {
            Lists(searchManager: searchManager)
                .searchable(
                    text: $searchManager.searchText,
                    placement: .navigationBarDrawer(displayMode: .always),
                    prompt: "Buscar"
                )
                .navigationDestination(isPresented: $isShowingSpotlightItemDetail) {
                    if let composer = selectedComposer {
                        ComposerDetail(composer: composer)
                    } else if let work = selectedWork {
                        WorkDetail(work: work)
                    } else if let artist = selectedArtist {
                        ArtistDetail(artist: artist)
                    } else {
                        EmptyView()
                    }
                }
                .onReceive(spotlightManager.$selectedItemId.compactMap { $0 }) { id in
                    selectedComposer = nil
                    selectedWork = nil
                    selectedArtist = nil

                    switch spotlightManager.selectedItemType {
                    case "composer":
                        if let composer = fetchById(Composer.self, id: id, using: modelContext) {
                            selectedComposer = composer
                            isShowingSpotlightItemDetail = true
                        }
                    case "work":
                        if let work = fetchById(Work.self, id: id, using: modelContext) {
                            selectedWork = work
                            isShowingSpotlightItemDetail = true
                        }
                    case "artist":
                        if let artist = fetchById(Artist.self, id: id, using: modelContext) {
                            selectedArtist = artist
                            isShowingSpotlightItemDetail = true
                        }
                    default:
                        break
                    }

                    DispatchQueue.main.async {
                        spotlightManager.selectedItemId = nil
                        spotlightManager.selectedItemType = nil
                    }
                }
        }
    }

    func fetchById<T: PersistentModel>(
        _ type: T.Type,
        id: UUID,
        using modelContext: ModelContext
    ) -> T? where T.ID == UUID {
        let predicate = #Predicate<T> { $0.id == id }
        let descriptor = FetchDescriptor<T>(predicate: predicate)

        return try? modelContext.fetch(descriptor).first
    }
}

struct Lists: View {
    @Environment(\.isSearching) private var isSearching: Bool
    @Environment(\.modelContext) private var modelContext: ModelContext

    @Query(sort: \Concert.date) private var concerts: [Concert]

    @ObservedObject var searchManager: SearchManager

    @State private var isExporting = false
    @State private var json: JsonDocument?

    var body: some View {
        if isSearching {
            List {
                if !filteredArtists.isEmpty {
                    ProminentSection("Artistas") {
                        ForEach(filteredArtists) { artist in
                            NavigationLink(destination: ArtistDetail(artist: artist)) {
                                MultilineArtistRow(artist: artist)
                            }
                        }
                    }
                }

                if !filteredComposers.isEmpty {
                    ProminentSection("Compositores") {
                        ForEach(filteredComposers) { composer in
                            NavigationLink(destination: ComposerDetail(composer: composer)) {
                                Text(composer.fullName)
                            }
                        }
                    }
                }

                if !filteredWorks.isEmpty {
                    ProminentSection("Obras") {
                        ForEach(filteredWorks) { work in
                            NavigationLink(destination: WorkDetail(work: work)) {
                                MultilineWorkRow(work: work)
                            }
                        }
                    }
                }
            }
        } else {
            let calendar = Calendar.current
            let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: Date())!
            let target = calendar.dateComponents([.year, .month, .day], from: oneYearAgo)
            let previousConcert = concerts.first { concert in
                return
                    calendar.dateComponents([.year, .month, .day], from: concert.date) == target
            }

            let nextConcert = concerts.first(where: { (concert: Concert) -> Bool in
                return concert.date > Date.now
            })

            List {
                if let previousConcert {
                    ProminentSection("Um ano atrás") {
                        NavigationLink {
                            ConcertDetail(concerts: [previousConcert], selected: previousConcert)
                        } label: {
                            let composerNames = Set(
                                previousConcert.performances.compactMap { $0.work.composer }
                            )
                            .map { $0.shortName }
                            .joined(separator: ", ")

                            HStack(alignment: .firstTextBaseline) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(previousConcert.title).fontWeight(.heavy)
                                    Text(composerNames).font(.footnote).foregroundColor(
                                        .secondary)
                                }
                            }
                        }
                    }
                }

                if let nextConcert {
                    ProminentSection("Próximo concerto") {
                        NavigationLink {
                            ConcertDetail(concerts: [nextConcert], selected: nextConcert)
                        } label: {
                            let composerNames = Set(
                                nextConcert.performances.compactMap { $0.work.composer }
                            )
                            .map { $0.shortName }
                            .joined(separator: ", ")

                            HStack(alignment: .firstTextBaseline) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(nextConcert.title).fontWeight(.heavy)
                                    Text(nextConcert.date.dayMonth)
                                    Text(composerNames).font(.footnote).foregroundColor(
                                        .secondary)
                                }
                            }
                        }
                    }
                }

                Section {
                    MainNavigationLink(
                        title: "Concertos", count: concertCount
                    ) { ConcertList() }

                    MainNavigationLink(
                        title: "Artistas", count: artistCount
                    ) { ArtistList() }

                    MainNavigationLink(
                        title: "Compositores", count: composerCount
                    ) {
                        ComposerList()
                    }
                }

                ProminentSection("Definições") {
                    MainNavigationLink(
                        title: ArtistType.self.pluralFormItemName, count: artistTypeCount
                    ) { NameableItemList<ArtistType>() }

                    MainNavigationLink(
                        title: Series.self.pluralFormItemName, count: seriesCount
                    ) { NameableItemList<Series>() }

                    MainNavigationLink(
                        title: MusicalForm.self.pluralFormItemName, count: formCount
                    ) { NameableItemList<MusicalForm>() }

                    MainNavigationLink(
                        title: Venue.self.pluralFormItemName, count: venueCount
                    ) { NameableItemList<Venue>() }
                }
            }
            .navigationTitle("Bach Tracking")
            .onAppear {
                UNUserNotificationCenter.current().requestAuthorization(
                    options: [.alert, .badge, .sound]) { _, _ in
                    }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        isExporting = true

                        let encoder = JSONEncoder()
                        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

                        if let jsonData = try? encoder.encode(concerts.map { ConcertDTO(from: $0) })
                        {
                            json = JsonDocument(json: jsonData)
                        }
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                    .fileExporter(
                        isPresented: $isExporting,
                        document: json,
                        contentType: .json,
                        defaultFilename: "bach-up.json",
                        onCompletion: { result in
                            print(result)
                        }
                    )
                }
            }
        }
    }

    var composerCount: Int { count(Composer.self, using: modelContext) }
    var artistCount: Int { count(Artist.self, using: modelContext) }
    var concertCount: Int { count(Concert.self, using: modelContext) }
    var artistTypeCount: Int { count(ArtistType.self, using: modelContext) }
    var seriesCount: Int { count(Series.self, using: modelContext) }
    var formCount: Int { count(MusicalForm.self, using: modelContext) }
    var venueCount: Int { count(Venue.self, using: modelContext) }

    var filteredArtists: [Artist] {
        let searchText = searchManager.debouncedSearchText

        return fetchModels(
            of: Artist.self,
            matching: #Predicate<Artist> { $0.name.localizedStandardContains(searchText) },
            using: modelContext)
    }

    var filteredComposers: [Composer] {
        let searchText = searchManager.debouncedSearchText

        return fetchModels(
            of: Composer.self,
            matching: #Predicate<Composer> { $0.fullName.localizedStandardContains(searchText) },
            using: modelContext)
    }

    var filteredWorks: [Work] {
        let searchText = searchManager.debouncedSearchText

        return fetchModels(
            of: Work.self,
            matching: #Predicate<Work> { $0.name.localizedStandardContains(searchText) },
            using: modelContext)
    }

    func count<T: PersistentModel>(_ type: T.Type, using modelContext: ModelContext) -> Int {
        (try? modelContext.fetchCount(FetchDescriptor<T>())) ?? 0
    }

    func fetchModels<T: PersistentModel>(
        of type: T.Type,
        matching predicate: Predicate<T>,
        using modelContext: ModelContext
    ) -> [T] {
        let descriptor = FetchDescriptor<T>(predicate: predicate)
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}

struct MainNavigationLink<Destination: View>: View {
    let title: String
    let count: Int
    let destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination()) {
            HStack {
                Text(title)
                Spacer()
                Text(String(count))
            }
        }
    }
}

struct JsonDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }
    var json: Data

    init(configuration: ReadConfiguration) throws {
        guard
            let data = configuration.file.regularFileContents
        else { throw NSError() }
        self.json = data
    }

    init(json: Data) {
        self.json = json
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: self.json)
    }
}

class SearchManager: ObservableObject {
    @Published var searchText = ""
    @Published var debouncedSearchText = ""

    private var cancellables: Set<AnyCancellable> = Set<AnyCancellable>()

    init() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .removeDuplicates()
            .sink { [weak self] value in
                self?.debouncedSearchText = value
            }
            .store(in: &cancellables)
    }
}

#Preview {
    ContentView()
}

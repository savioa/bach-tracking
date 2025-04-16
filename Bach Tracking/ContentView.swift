import Combine
import SwiftData
import SwiftUI

struct ContentView: View {
    @StateObject private var searchManager: SearchManager = SearchManager()
    @EnvironmentObject var spotlightManager: SpotlightNavigationManager

    @Query private var composers: [Composer]
    @Query private var works: [Work]
    @Query private var artists: [Artist]

    @State private var navigationPath: NavigationPath = NavigationPath()

    @State private var isShowingSpotlightItemDetail: Bool = false
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
                    if let composer: Composer = selectedComposer {
                        ComposerDetail(composer: composer)
                    } else if let work: Work = selectedWork {
                        WorkDetail(work: work)
                    } else if let artist: Artist = selectedArtist {
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
                        if let composer: Composer = composers.first(where: { $0.id == id }) {
                            selectedComposer = composer
                            isShowingSpotlightItemDetail = true
                        }
                    case "work":
                        if let work: Work = works.first(where: { $0.id == id }) {
                            selectedWork = work
                            isShowingSpotlightItemDetail = true
                        }
                    case "artist":
                        if let artist: Artist = artists.first(where: { $0.id == id }) {
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
}

struct Lists: View {
    @Environment(\.isSearching) private var isSearching: Bool

    @Query(sort: \Concert.date) private var concerts: [Concert]
    @Query private var composers: [Composer]
    @Query private var artists: [Artist]
    @Query private var artistTypes: [ArtistType]
    @Query private var seriesList: [Series]
    @Query private var venues: [Venue]
    @Query private var forms: [MusicalForm]
    @Query private var works: [Work]

    @ObservedObject var searchManager: SearchManager

    var body: some View {
        if isSearching {
            List {
                if !filteredArtists.isEmpty {
                    Section("Artistas") {
                        ForEach(filteredArtists) { artist in
                            NavigationLink(destination: ArtistDetail(artist: artist)) {
                                MultilineArtistRow(artist: artist)
                            }
                        }
                    }
                    .headerProminence(.increased)
                }

                if !filteredComposers.isEmpty {
                    Section("Compositores") {
                        ForEach(filteredComposers) { composer in
                            NavigationLink(destination: ComposerDetail(composer: composer)) {
                                Text(composer.fullName)
                            }
                        }
                    }
                    .headerProminence(.increased)
                }

                if !filteredWorks.isEmpty {
                    Section("Obras") {
                        ForEach(filteredWorks) { work in
                            NavigationLink(destination: WorkDetail(work: work)) {
                                MultilineWorkRow(work: work)
                            }
                        }
                    }
                    .headerProminence(.increased)
                }
            }
        } else {
            let nextConcert: Concert? = concerts.first(where: { (concert: Concert) -> Bool in
                return concert.date > Date.now
            })

            List {
                if let nextConcert: Concert {
                    Section(header: Text("Próximo concerto")) {
                        NavigationLink {
                            ConcertDetail(concert: nextConcert)
                        } label: {
                            let composerNames: String = Set(
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
                    .headerProminence(.increased)
                }
                Section {
                    MainNavigationLink(
                        title: "Concertos", count: concerts.count
                    ) { ConcertList() }

                    MainNavigationLink(
                        title: "Artistas", count: artists.count
                    ) { ArtistList() }

                    MainNavigationLink(
                        title: "Compositores", count: composers.count
                    ) {
                        ComposerList()
                    }
                }

                Section(header: Text("Definições")) {
                    MainNavigationLink(
                        title: ArtistType.self.pluralFormItemName, count: artistTypes.count
                    ) { NameableItemList<ArtistType>() }

                    MainNavigationLink(
                        title: Series.self.pluralFormItemName, count: seriesList.count
                    ) { NameableItemList<Series>() }

                    MainNavigationLink(
                        title: MusicalForm.self.pluralFormItemName, count: forms.count
                    ) { NameableItemList<MusicalForm>() }

                    MainNavigationLink(
                        title: Venue.self.pluralFormItemName, count: venues.count
                    ) { NameableItemList<Venue>() }
                }
                .headerProminence(.increased)
            }
            .navigationTitle("Bach Tracking")
            .onAppear {
                let encoder: JSONEncoder = JSONEncoder()
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

                concerts.forEach { concert in
                    if let jsonData: Data = try? encoder.encode(ConcertDTO(from: concert)),
                        let jsonString: String = String(data: jsonData, encoding: .utf8)
                    {
                        print(jsonString)
                    }
                }
            }
        }
    }

    var filteredArtists: [Artist] {
        artists.filter {
            $0.name.localizedCaseInsensitiveContains(searchManager.debouncedSearchText)
        }
    }

    var filteredComposers: [Composer] {
        composers.filter {
            $0.fullName.localizedCaseInsensitiveContains(searchManager.debouncedSearchText)
        }
    }

    var filteredWorks: [Work] {
        works.filter {
            $0.primaryTitle.localizedCaseInsensitiveContains(searchManager.debouncedSearchText)
                || $0.derivedTitle.localizedCaseInsensitiveContains(
                    searchManager.debouncedSearchText)
        }
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

class SearchManager: ObservableObject {
    @Published var searchText: String = ""
    @Published var debouncedSearchText: String = ""

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

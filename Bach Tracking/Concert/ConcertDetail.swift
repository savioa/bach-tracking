import SwiftData
import SwiftUI

struct ConcertDetail: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext

    @State private var isEditing: Bool = false
    @State private var isDeleting: Bool = false

    @Query private var concerts: [Concert]

    let concert: Concert

    var body: some View {
        List {
            Text("\(concert.date.formatted()) - \(concert.venue.name)").listRowSeparator(.hidden)

            Section(header: Text("Obras")) {
                ForEach(concert.performances) { performance in
                    NavigationLink {
                        WorkDetail(work: performance.work)
                    } label: {
                        MultilinePerformanceRow(performance: performance)
                    }
                }
            }
            .headerProminence(.increased)

            Section(header: Text("Artistas")) {
                let artists: [Artist] = Set(concert.performances.flatMap { $0.artists })
                    .sorted { $0.name < $1.name }

                ForEach(artists) { artist in
                    NavigationLink {
                        ArtistDetail(artist: artist)
                    } label: {
                        MultilineArtistRow(artist: artist)
                    }
                }
            }
            .headerProminence(.increased)

            if concert.title.count > 20 {
                Section("Nome") {
                    Text(concert.title)
                }
                .headerProminence(.increased)
            }
        }
        .listStyle(.plain)
        .navigationTitle(concert.title)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $isEditing) {
            ConcertEditor(concert: concert)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Editar") { isEditing = true }
            }
        }

        Button("Apagar", role: .destructive) { isDeleting = true }
            .buttonStyle(.bordered)
            .tint(.red)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
            .confirmationDialog(
                "Tem certeza de que deseja apagar este concerto?",
                isPresented: $isDeleting,
                titleVisibility: .visible
            ) {
                DeleteButton(item: concert) {
                    concert.performances.forEach { performance in
                        modelContext.delete(performance)
                    }
                }
            }
    }
}

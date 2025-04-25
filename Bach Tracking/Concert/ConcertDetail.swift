import SwiftData
import SwiftUI

struct InnerConcertDetail: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext

    @State private var isEditing = false
    @State private var isDeleting = false

    let concert: Concert

    var body: some View {
        List {
            Text("\(concert.date.formatted()) - \(concert.venue.name)").listRowSeparator(.hidden)

            ProminentSection("Obras") {
                ForEach(concert.performances.sorted { !$0.encore && $1.encore }) { performance in
                    NavigationLink {
                        WorkDetail(work: performance.work)
                    } label: {
                        MultilinePerformanceRow(performance: performance)
                    }
                }
            }

            ProminentSection("Artistas") {
                let artists = Set(concert.performances.flatMap { $0.artists })
                    .sorted { $0.name < $1.name }

                ForEach(artists) { artist in
                    NavigationLink {
                        ArtistDetail(artist: artist)
                    } label: {
                        MultilineArtistRow(artist: artist)
                    }
                }
            }

            if concert.title.count > 20 {
                ProminentSection("Nome") { Text(concert.title) }
            }
        }
        .listStyle(.plain)
        .navigationTitle(concert.title)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $isEditing) {
            ConcertEditor(concert: concert)
        }
        .toolbar { EditButtonToolbarItem(isEditing: $isEditing) }

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

                    UNUserNotificationCenter.current().removePendingNotificationRequests(
                        withIdentifiers: [concert.id.uuidString])
                }
            }
    }
}

struct ConcertDetail: View {
    let concerts: [Concert]
    @State private var currentIndex: Int

    init(concerts: [Concert], selected: Concert) {
        self.concerts = concerts
        _currentIndex = State(
            initialValue: concerts.firstIndex(where: { $0.id == selected.id }) ?? 0)
    }

    var body: some View {
        InnerConcertDetail(concert: concerts[currentIndex])
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width < -50 {
                            if currentIndex < concerts.count - 1 {
                                currentIndex += 1
                            } else {
                                currentIndex = 0
                            }
                        } else if value.translation.width > 50 {
                            if currentIndex > 0 {
                                currentIndex -= 1
                            } else {
                                currentIndex = concerts.count - 1
                            }
                        }
                    }
            )
            .animation(.easeInOut, value: currentIndex)
    }
}

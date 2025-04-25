import CoreSpotlight
import SwiftData
import SwiftUI

struct WorkDetail: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext

    @State private var isEditing = false

    let work: Work

    var body: some View {
        List {
            if work.hasDerivedTitle() {
                Section {
                    Text(work.derivedTitle).listRowSeparator(.hidden)
                }
            }

            ProminentSection("Compositor") {
                NavigationLink {
                    ComposerDetail(composer: work.composer)
                } label: {
                    Text(work.composer.fullName)
                }
            }

            if !work.performances.isEmpty {
                ProminentSection("Execuções") {
                    let concerts: [Concert] = Array(
                        Set(work.performances.compactMap { $0.concert })
                    ).sorted { $0.date > $1.date }

                    ForEach(concerts) { concert in
                        NavigationLink {
                            ConcertDetail(concerts: concerts, selected: concert)
                        } label: {
                            MultilineRow(
                                firstLine: Text(concert.title),
                                secondLine: Text(concert.date.formatted()))
                        }
                    }
                }
            }

            if work.primaryTitle.count > 20 {
                ProminentSection("Título") { Text(work.primaryTitle) }
            }
        }
        .listStyle(.plain)
        .navigationTitle(work.primaryTitle)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $isEditing) {
            WorkEditor(work: work, composer: work.composer)
        }
        .toolbar { EditButtonToolbarItem(isEditing: $isEditing) }

        if work.performances.isEmpty {
            DeleteButton(item: work) {
                CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [
                    "work.\(work.id.uuidString)"
                ])
            }
        }
    }
}

#Preview {
    let symphony = MusicalForm(name: "Sinfonia")
    let bizet = Composer(fullName: "Georges Bizet", shortName: "Bizet")
    let roma = Work(
        name: "Roma",
        detail: "",
        opus: "",
        catalogue: "GB 118",
        form: symphony,
        tonality: Work.Tonality.cMajor,
        nickname: "",
        number: "",
        composer: bizet,
        instruments: ""
    )

    NavigationStack {
        WorkDetail(work: roma)
    }
}

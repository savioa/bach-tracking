import CoreSpotlight
import SwiftData
import SwiftUI

struct WorkDetail: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext

    @State private var isEditing: Bool = false

    let work: Work

    var body: some View {
        List {
            if work.hasDerivedTitle() {
                Section {
                    Text(work.derivedTitle).listRowSeparator(.hidden)
                }
            }

            Section("Compositor") {
                NavigationLink {
                    ComposerDetail(composer: work.composer)
                } label: {
                    Text(work.composer.fullName)
                }
            }
            .headerProminence(.increased)

            if !work.performances.isEmpty {
                Section("Execuções") {
                    let concerts: [Concert] = Array(Set(work.performances.compactMap { $0.concert }))

                    ForEach(concerts.sorted { $0.date > $1.date }
                    ) { performance in
                        NavigationLink {
                            ConcertDetail(concert: performance)
                        } label: {
                            MultilineRow(
                                firstLine: Text(performance.title),
                                secondLine: Text(performance.date.formatted()))
                        }
                    }
                }
                .headerProminence(.increased)
            }

            if work.primaryTitle.count > 20 {
                Section("Título") {
                    Text(work.primaryTitle)
                }
                .headerProminence(.increased)
            }
        }
        .listStyle(.plain)
        .navigationTitle(work.primaryTitle)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $isEditing) {
            WorkEditor(work: work, composer: work.composer)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Editar") { isEditing = true }
            }
        }

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
        tonality: Work.Tonality.c,
        nickname: "",
        number: "",
        composer: bizet,
        instruments: ""
    )

    NavigationStack {
        WorkDetail(work: roma)
    }
}

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
                    ForEach(
                        work.performances.sorted { $0.concert!.date > $1.concert!.date }
                    ) { performance in
                        NavigationLink {
                            ConcertDetail(concert: performance.concert!)
                        } label: {
                            MultilineRow(
                                firstLine: Text(performance.concert!.title),
                                secondLine: Text(performance.concert!.date.formatted()))
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

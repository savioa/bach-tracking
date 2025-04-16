import CoreSpotlight
import SwiftData
import SwiftUI

struct ComposerDetail: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext

    @State private var isEditing: Bool = false
    @State private var isAddingWork: Bool = false

    let composer: Composer

    var body: some View {
        List {
            Text(composer.fullName).listRowSeparator(.hidden).font(.largeTitle).bold()

            Portrait(name: composer.shortName)

            Section(
                header: SectionHeaderWithAddButton(
                    sectionHeaderText: "Obras", accessibilityLabel: "Adicionar nova obra",
                    isAdding: $isAddingWork)
            ) {
                if composer.works.isEmpty {
                    Text("Nenhuma obra cadastrada")
                } else {
                    ForEach(composer.works) { work in
                        NavigationLink {
                            WorkDetail(work: work)
                        } label: {
                            MultilineWorkRow(work: work)
                        }
                    }
                }
            }
            .headerProminence(.increased)
        }
        .listStyle(.plain)
        .navigationTitle(composer.shortName)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isEditing) {
            ComposerEditor(composer: composer)
        }
        .sheet(isPresented: $isAddingWork) {
            WorkEditor(work: nil, composer: composer)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Editar") { isEditing = true }
            }
        }

        if composer.works.isEmpty {
            DeleteButton(item: composer) {
                CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [
                    "composer.\(composer.id.uuidString)"
                ])
            }
        }
    }
}

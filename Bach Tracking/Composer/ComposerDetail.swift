import CoreSpotlight
import SwiftData
import SwiftUI

struct ComposerDetail: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext

    @State private var isEditing = false
    @State private var isAddingWork = false

    let composer: Composer

    var body: some View {
        List {
            Text(composer.fullName).listRowSeparator(.hidden).font(.largeTitle).bold()

            Portrait(name: composer.shortName)

            ProminentSection(
                header: SectionHeaderWithAddButton(
                    sectionHeaderText: "Obras", accessibilityLabel: "Adicionar nova obra",
                    isAdding: $isAddingWork)
            ) {
                if composer.works.isEmpty {
                    Text("Nenhuma obra cadastrada")
                } else {
                    ForEach(composer.works.sorted { $0.primaryTitle < $1.primaryTitle }) { work in
                        NavigationLink {
                            WorkDetail(work: work)
                        } label: {
                            MultilineWorkRow(work: work)
                        }
                    }
                }
            }
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
        .toolbar { EditButtonToolbarItem(isEditing: $isEditing) }

        if composer.works.isEmpty {
            DeleteButton(item: composer) {
                CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [
                    "composer.\(composer.id.uuidString)"
                ])
            }
        }
    }
}

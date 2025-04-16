import SwiftData
import SwiftUI

struct NameableItemDetail<T: Nameable & PersistentModel>: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext

    @State private var isEditing: Bool = false

    let item: T

    var body: some View {
        List {
            if item.getUsageCount() > 0 {
                let usageLinks: [AnyView] = item.getUsageLinks()

                Section(header: Text(T.dependentItemName)) {
                    ForEach(usageLinks.indices, id: \.self) { index in
                        usageLinks[index]
                    }
                }
                .headerProminence(.increased)
            }
        }
        .listStyle(.plain)
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $isEditing) {
            NameableItemEditor(item: item)
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Editar") { isEditing = true }
            }
        }

        if item.getUsageCount() == 0 {
            DeleteButton(item: item)
        }
    }
}

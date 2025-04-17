import SwiftData
import SwiftUI

struct NameableItemDetail<T: Nameable & PersistentModel>: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext

    @State private var isEditing = false

    let item: T

    var body: some View {
        List {
            if item.getUsageCount() > 0 {
                let usageLinks: [AnyView] = item.getUsageLinks()

                ProminentSection(T.dependentItemName) {
                    ForEach(usageLinks.indices, id: \.self) { index in
                        usageLinks[index]
                    }
                }
            }
        }
        .listStyle(.plain)
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $isEditing) {
            NameableItemEditor(item: item)
        }
        .toolbar { EditButtonToolbarItem(isEditing: $isEditing) }

        if item.getUsageCount() == 0 {
            DeleteButton(item: item)
        }
    }
}

import SwiftData
import SwiftUI

struct NameableItemEditor<T: Nameable & PersistentModel>: View {
    @Environment(\.dismiss) var dismiss: DismissAction
    @Environment(\.modelContext) private var modelContext: ModelContext

    @FocusState private var focusedField: Bool

    @State private var name = ""
    @State private var navigationTitle = T.newItemLabel

    let item: T?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Nome", text: $name)
                        .focused($focusedField)
                }
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                FormToolbar.items(isConfirmDisabled: name.isEmpty, onConfirm: { save() })
            }
        }
        .onAppear {
            if let item: T {
                name = item.name
                navigationTitle = ""
            } else {
                focusedField = true
            }
        }
    }

    func save() {
        if var item: T {
            item.name = name.trimmed
        } else {
            let item: T = T(name: name.trimmed)

            modelContext.insert(item)
        }

        try? modelContext.save()

        dismiss()
    }
}
